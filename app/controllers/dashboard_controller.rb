class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index? # Folosim o politică generală sau ApplicationPolicy

    # Folosim policy_scope pentru a ne asigura că vedem doar ce avem voie
    @recent_test_runs = policy_scope(TestRun).includes(:project).order(created_at: :desc).limit(5)
    @upcoming_milestones = policy_scope(Milestone).includes(:project).where('due_date >= ?', Date.today).order(due_date: :asc).limit(5)

    # Statistici generale (pot fi costisitoare, consideră caching sau optimizare)
    # Asigură-te că policy_scope este aplicat corect dacă filtrezi la nivel de user
    @total_projects = policy_scope(Project).count
    @total_test_suites = policy_scope(TestSuite).count
    @total_test_cases = policy_scope(TestCase).count
    @total_test_runs = policy_scope(TestRun).count
  end
end