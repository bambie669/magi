class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index?

    # Stats for cards
    @active_test_runs = policy_scope(TestRun).where('created_at >= ?', 30.days.ago).count
    @tests_in_progress = policy_scope(TestRunCase).where(status: 'untested').count

    # Automation results (passed/failed from recent runs)
    recent_run_cases = policy_scope(TestRunCase).joins(:test_run).where('test_runs.created_at >= ?', 30.days.ago)
    @passed_count = recent_run_cases.where(status: 'passed').count
    @failed_count = recent_run_cases.where(status: 'failed').count

    # Recent test runs with details
    @recent_test_runs = policy_scope(TestRun).includes(:project).order(created_at: :desc).limit(5)

    # Upcoming milestones
    @upcoming_milestones = policy_scope(Milestone).includes(:project).where('due_date >= ?', Date.today).order(due_date: :asc).limit(5)

    # Overall stats
    @total_projects = policy_scope(Project).count
    @total_test_suites = policy_scope(TestSuite).count
    @total_test_cases = policy_scope(TestCase).count
    @total_test_runs = policy_scope(TestRun).count

    # Telemetry chart data (last 14 days)
    @telemetry_data = build_telemetry_data

    # Pass rate trend (last 30 days)
    @pass_rate_trend = build_pass_rate_trend

    # Top failed tests
    @top_failed_tests = build_top_failed_tests

    # Team activity feed
    @team_activity = build_team_activity

    # Activity heatmap data (last 365 days)
    @activity_heatmap = build_activity_heatmap
  end

  private

  def build_telemetry_data
    # Get data for the last 14 days
    days = 14
    end_date = Date.today
    start_date = end_date - (days - 1).days

    # Initialize data structure
    labels = []
    passed = []
    failed = []
    blocked = []

    (start_date..end_date).each do |date|
      labels << date.strftime('%m/%d')

      # Count test run cases updated on this date with each status
      day_cases = policy_scope(TestRunCase)
        .joins(:test_run)
        .where('DATE(test_run_cases.updated_at) = ?', date)
        .where.not(status: 'untested')

      passed << day_cases.where(status: 'passed').count
      failed << day_cases.where(status: 'failed').count
      blocked << day_cases.where(status: 'blocked').count
    end

    {
      labels: labels,
      passed: passed,
      failed: failed,
      blocked: blocked
    }
  end

  def build_pass_rate_trend
    days = 30
    end_date = Date.today
    start_date = end_date - (days - 1).days

    labels = []
    rates = []

    (start_date..end_date).each do |date|
      labels << date.strftime('%m/%d')

      day_cases = policy_scope(TestRunCase)
        .joins(:test_run)
        .where('DATE(test_run_cases.updated_at) = ?', date)
        .where.not(status: 'untested')

      total = day_cases.count
      passed = day_cases.where(status: 'passed').count

      rate = total > 0 ? ((passed.to_f / total) * 100).round(1) : nil
      rates << rate
    end

    { labels: labels, rates: rates }
  end

  def build_top_failed_tests
    # Get test cases that have failed most often in the last 30 days
    policy_scope(TestRunCase)
      .joins(:test_run, :test_case)
      .where('test_run_cases.updated_at >= ?', 30.days.ago)
      .where(status: 'failed')
      .group('test_cases.id', 'test_cases.title')
      .order(Arel.sql('COUNT(*) DESC'))
      .limit(5)
      .pluck('test_cases.id', 'test_cases.title', Arel.sql('COUNT(*) as fail_count'))
      .map { |id, title, count| { id: id, title: title, fail_count: count } }
  end

  def build_team_activity
    # Recent test executions with user info
    policy_scope(TestRunCase)
      .joins(:test_run, :test_case)
      .joins('LEFT JOIN users ON test_run_cases.user_id = users.id')
      .where('test_run_cases.updated_at >= ?', 7.days.ago)
      .where.not(status: 'untested')
      .order('test_run_cases.updated_at DESC')
      .limit(10)
      .select(
        'test_run_cases.id',
        'test_run_cases.status',
        'test_run_cases.updated_at',
        'test_cases.title as test_title',
        'test_runs.name as run_name',
        'users.email as user_email'
      )
  end

  def build_activity_heatmap
    # Get activity counts for the last 365 days
    end_date = Date.today
    start_date = end_date - 364.days

    activity = policy_scope(TestRunCase)
      .joins(:test_run)
      .where('DATE(test_run_cases.updated_at) BETWEEN ? AND ?', start_date, end_date)
      .where.not(status: 'untested')
      .group('DATE(test_run_cases.updated_at)')
      .count

    # Convert to hash with date strings
    activity.transform_keys { |date| date.to_s }
  end
end