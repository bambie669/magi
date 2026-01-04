class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      # Search across all entities
      @projects = policy_scope(Project).where("name ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%").limit(10)
      @test_suites = policy_scope(TestSuite).where("name ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%").limit(10)
      @test_cases = policy_scope(TestCase).where("title ILIKE ? OR preconditions ILIKE ? OR steps ILIKE ? OR expected_result ILIKE ?", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%").limit(20)
      @test_runs = policy_scope(TestRun).where("name ILIKE ?", "%#{@query}%").limit(10)

      @total_results = @projects.size + @test_suites.size + @test_cases.size + @test_runs.size
    else
      @projects = []
      @test_suites = []
      @test_cases = []
      @test_runs = []
      @total_results = 0
    end
  end
end
