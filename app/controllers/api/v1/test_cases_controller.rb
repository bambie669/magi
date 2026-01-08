module Api
  module V1
    class TestCasesController < BaseController
      before_action :set_test_suite, only: [:index]
      before_action :set_test_case, only: [:show]

      # GET /api/v1/test_suites/:test_suite_id/test_cases
      def index
        authorize @test_suite, :show?
        @test_cases = @test_suite.test_cases
        render json: @test_cases.map { |tc| test_case_json(tc) }
      end

      # GET /api/v1/test_cases/:id
      def show
        authorize @test_case
        render json: test_case_json(@test_case, full: true)
      end

      # GET /api/v1/test_cases/by_cypress_id/:cypress_id
      def by_cypress_id
        @test_case = TestCase.find_by!(cypress_id: params[:cypress_id])
        authorize @test_case
        render json: test_case_json(@test_case, full: true)
      end

      private

      def set_test_suite
        @test_suite = TestSuite.find(params[:test_suite_id])
      end

      def set_test_case
        @test_case = TestCase.find(params[:id])
      end

      def test_case_json(test_case, full: false)
        data = {
          id: test_case.id,
          title: test_case.title,
          cypress_id: test_case.cypress_id,
          test_suite_id: test_case.test_suite_id,
          test_suite_name: test_case.test_suite.name,
          created_at: test_case.created_at.iso8601,
          updated_at: test_case.updated_at.iso8601
        }

        if full
          data[:preconditions] = test_case.preconditions
          data[:steps] = test_case.steps
          data[:expected_result] = test_case.expected_result
          data[:execution_history] = test_case.test_run_cases.includes(:test_run, :user)
            .order(created_at: :desc)
            .limit(10)
            .map do |trc|
              {
                test_run_id: trc.test_run_id,
                test_run_name: trc.test_run.name,
                status: trc.status,
                executor: trc.user&.display_name,
                executed_at: trc.updated_at.iso8601
              }
            end
        end

        data
      end
    end
  end
end
