module Api
  module V1
    class TestRunCasesController < BaseController
      before_action :set_test_run_case

      # PATCH /api/v1/test_run_cases/:id
      def update
        test_run = @test_run_case.test_run
        authorize test_run, :update?

        # Set the executor if status is changing from untested
        if @test_run_case.status_was == 'untested' && test_run_case_params[:status] != 'untested' && @test_run_case.user_id.nil?
          @test_run_case.user = current_user
        end

        if @test_run_case.update(test_run_case_params)
          # Broadcast update to all subscribers
          broadcast_test_run_update(test_run)

          render json: test_run_case_json(@test_run_case)
        else
          render json: { errors: @test_run_case.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/test_run_cases/bulk_update
      def bulk_update
        results = {
          updated: 0,
          errors: []
        }

        params[:updates].each do |update|
          trc = TestRunCase.find_by(id: update[:id])
          next unless trc

          test_run = trc.test_run
          next unless Pundit.policy(current_user, test_run).update?

          if trc.status_was == 'untested' && update[:status] != 'untested' && trc.user_id.nil?
            trc.user = current_user
          end

          if trc.update(status: update[:status], comments: update[:comments])
            results[:updated] += 1
            broadcast_test_run_update(test_run)
          else
            results[:errors] << { id: update[:id], errors: trc.errors.full_messages }
          end
        end

        render json: results
      end

      private

      def set_test_run_case
        @test_run_case = TestRunCase.find(params[:id])
      end

      def test_run_case_params
        params.permit(:status, :comments)
      end

      def broadcast_test_run_update(test_run)
        TestRunChannel.broadcast_to(test_run, {
          type: 'status_update',
          test_run_case_id: @test_run_case.id,
          status: @test_run_case.status,
          user_name: @test_run_case.user&.display_name,
          passed_count: test_run.passed_cases,
          failed_count: test_run.failed_cases,
          blocked_count: test_run.blocked_cases,
          untested_count: test_run.untested_cases,
          completion_percentage: test_run.completion_percentage
        })
      rescue => e
        Rails.logger.error("Failed to broadcast test run update: #{e.message}")
      end

      def test_run_case_json(trc)
        {
          id: trc.id,
          test_case_id: trc.test_case_id,
          title: trc.test_case.title,
          cypress_id: trc.test_case.cypress_id,
          status: trc.status,
          executor: trc.user&.display_name,
          comments: trc.comments,
          test_run: {
            id: trc.test_run_id,
            name: trc.test_run.name,
            passed: trc.test_run.passed_cases,
            failed: trc.test_run.failed_cases,
            blocked: trc.test_run.blocked_cases,
            untested: trc.test_run.untested_cases,
            completion_percentage: trc.test_run.completion_percentage
          }
        }
      end
    end
  end
end
