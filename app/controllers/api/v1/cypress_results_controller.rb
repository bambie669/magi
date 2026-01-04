module Api
  module V1
    class CypressResultsController < BaseController
      before_action :set_test_run

      def create
        authorize @test_run, :update?

        results = params[:results] || []
        summary = process_results(results)

        render json: {
          message: 'Results processed successfully',
          test_run_id: @test_run.id,
          summary: summary
        }, status: :ok
      end

      private

      def set_test_run
        @test_run = TestRun.find(params[:test_run_id])
      end

      def process_results(results)
        summary = {
          total: results.size,
          updated: 0,
          not_found: 0,
          errors: []
        }

        results.each do |result|
          cypress_id = result[:cypress_id] || result['cypress_id']
          status = result[:status] || result['status']
          error_message = result[:error_message] || result['error_message']
          duration_ms = result[:duration_ms] || result['duration_ms']

          test_case = TestCase.find_by(cypress_id: cypress_id)

          unless test_case
            summary[:not_found] += 1
            summary[:errors] << "TestCase with cypress_id '#{cypress_id}' not found"
            next
          end

          test_run_case = @test_run.test_run_cases.find_by(test_case_id: test_case.id)

          unless test_run_case
            summary[:not_found] += 1
            summary[:errors] << "TestCase '#{cypress_id}' is not part of this test run"
            next
          end

          mapped_status = map_cypress_status(status)
          comments = build_comments(error_message, duration_ms, test_run_case.comments)

          if test_run_case.update(status: mapped_status, comments: comments, user: current_user)
            summary[:updated] += 1
          else
            summary[:errors] << "Failed to update TestCase '#{cypress_id}': #{test_run_case.errors.full_messages.join(', ')}"
          end
        end

        summary
      end

      def map_cypress_status(cypress_status)
        case cypress_status.to_s.downcase
        when 'passed'
          :passed
        when 'failed'
          :failed
        when 'skipped', 'pending'
          :blocked
        else
          :untested
        end
      end

      def build_comments(error_message, duration_ms, existing_comments)
        parts = []
        parts << "[Cypress] Duration: #{duration_ms}ms" if duration_ms
        parts << "[Cypress] Error: #{error_message}" if error_message.present?

        new_comment = parts.join("\n")
        return new_comment if existing_comments.blank?

        "#{existing_comments}\n\n---\n#{new_comment}"
      end
    end
  end
end
