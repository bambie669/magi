module Api
  module V1
    class TestRunsController < BaseController
      before_action :set_project, only: [:index, :create]
      before_action :set_test_run, only: [:show, :update]

      # GET /api/v1/projects/:project_id/test_runs
      def index
        authorize @project, :show?
        @test_runs = @project.test_runs.order(created_at: :desc)
        render json: @test_runs.map { |tr| test_run_json(tr) }
      end

      # GET /api/v1/test_runs/:id
      def show
        authorize @test_run
        render json: test_run_json(@test_run, full: true)
      end

      # POST /api/v1/projects/:project_id/test_runs
      def create
        authorize @project, :update?
        @test_run = @project.test_runs.build(test_run_params)
        @test_run.user = current_user

        if @test_run.save
          # Create test run cases for all test cases in the selected test suites
          if params[:test_suite_ids].present?
            create_test_run_cases(params[:test_suite_ids])
          end

          render json: test_run_json(@test_run), status: :created
        else
          render json: { errors: @test_run.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/test_runs/:id
      def update
        authorize @test_run

        if @test_run.update(test_run_params)
          render json: test_run_json(@test_run)
        else
          render json: { errors: @test_run.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_test_run
        @test_run = TestRun.find(params[:id])
      end

      def test_run_params
        params.permit(:name, :description, :milestone_id)
      end

      def create_test_run_cases(test_suite_ids)
        TestSuite.where(id: test_suite_ids, project: @project).each do |suite|
          suite.test_cases.each do |test_case|
            @test_run.test_run_cases.create(test_case: test_case, status: :untested)
          end
        end
      end

      def test_run_json(test_run, full: false)
        data = {
          id: test_run.id,
          name: test_run.name,
          description: test_run.description,
          project_id: test_run.project_id,
          project_name: test_run.project.name,
          user: test_run.user&.display_name,
          milestone: test_run.milestone&.name,
          status: {
            total_cases: test_run.test_run_cases.count,
            passed: test_run.passed_cases,
            failed: test_run.failed_cases,
            blocked: test_run.blocked_cases,
            untested: test_run.untested_cases,
            completion_percentage: test_run.completion_percentage
          },
          created_at: test_run.created_at.iso8601,
          updated_at: test_run.updated_at.iso8601
        }

        if full
          data[:test_cases] = test_run.test_run_cases.includes(:test_case, :user).map do |trc|
            {
              id: trc.id,
              test_case_id: trc.test_case_id,
              title: trc.test_case.title,
              cypress_id: trc.test_case.cypress_id,
              status: trc.status,
              executor: trc.user&.display_name,
              comments: trc.comments
            }
          end
        end

        data
      end
    end
  end
end
