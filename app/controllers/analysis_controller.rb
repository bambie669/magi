class AnalysisController < ApplicationController
  before_action :authenticate_user!

  def index
    # Overall statistics
    @total_projects = policy_scope(Project).count
    @total_test_suites = policy_scope(TestSuite).count
    @total_test_cases = policy_scope(TestCase).count
    @total_test_runs = policy_scope(TestRun).count

    # Test case results (from test_run_cases)
    test_run_cases = TestRunCase.joins(test_run: :project).merge(policy_scope(Project).joins(:test_runs))
    @passed_count = test_run_cases.where(status: 'passed').count
    @failed_count = test_run_cases.where(status: 'failed').count
    @blocked_count = test_run_cases.where(status: 'blocked').count
    @untested_count = test_run_cases.where(status: ['untested', nil]).count

    # Calculate pass rate
    total_tested = @passed_count + @failed_count + @blocked_count
    @pass_rate = total_tested > 0 ? ((@passed_count.to_f / total_tested) * 100).round(1) : 0

    # Recent activity (last 30 days)
    @recent_runs = policy_scope(TestRun).where('created_at > ?', 30.days.ago).order(created_at: :desc).limit(10)

    # Runs by project (for chart)
    @runs_by_project = policy_scope(TestRun)
      .joins(:project)
      .group('projects.name')
      .count
      .sort_by { |_, v| -v }
      .first(10)
      .to_h

    # Daily test execution (last 14 days)
    @daily_executions = test_run_cases
      .where('test_run_cases.updated_at > ?', 14.days.ago)
      .where.not(status: ['untested', nil])
      .group("DATE(test_run_cases.updated_at)")
      .count
      .transform_keys { |k| k.strftime('%m/%d') }

    # Top projects by test cases
    @top_projects = policy_scope(Project)
      .left_joins(test_suites: { test_scopes: :test_cases })
      .group('projects.id', 'projects.name')
      .select('projects.id, projects.name, COUNT(test_cases.id) as test_count')
      .order('test_count DESC')
      .limit(5)
  end
end
