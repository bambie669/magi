module Api
  module V1
    class CypressResultsController < BaseController
      before_action :set_test_run, only: [:create]
      before_action :set_project, only: [:create_for_project]

      # POST /api/v1/projects/:project_id/cypress_results
      # Auto-creates or finds a test run for today
      def create_for_project
        authorize @project, :update?

        @test_run = find_or_create_test_run

        results = params[:results] || []
        summary = process_results(results)

        render json: {
          message: 'Results processed successfully',
          project_id: @project.id,
          test_run_id: @test_run.id,
          test_run_name: @test_run.name,
          summary: summary
        }, status: :ok
      end

      # POST /api/v1/test_runs/:test_run_id/cypress_results
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

      def set_project
        @project = Project.find(params[:project_id])
      end

      def find_or_create_test_run
        today = Date.current
        run_name = params[:run_name].presence || "Cypress Run - #{today.strftime('%Y-%m-%d')}"

        # Try to find existing run with same name from today
        existing_run = @project.test_runs
                               .where('DATE(created_at) = ?', today)
                               .find_by(name: run_name)

        return existing_run if existing_run

        # Create new test run
        @project.test_runs.create!(
          name: run_name,
          user: current_user
        )
      end

      def process_results(results)
        summary = {
          total: results.size,
          updated: 0,
          created: 0,
          not_found: 0,
          errors: []
        }

        results.each do |result|
          cypress_id = result[:cypress_id] || result['cypress_id']
          status = result[:status] || result['status']
          error_message = result[:error_message] || result['error_message']
          duration_ms = result[:duration_ms] || result['duration_ms']
          test_title = result[:title] || result['title']

          test_case = find_test_case_by_cypress_id(cypress_id)

          # Auto-create test case if not found and auto_create is enabled
          if test_case.nil? && ActiveModel::Type::Boolean.new.cast(params[:auto_create])
            test_case = create_test_case(cypress_id, test_title)
            summary[:created] += 1 if test_case
          end

          unless test_case
            summary[:not_found] += 1
            summary[:errors] << "TestCase with cypress_id '#{cypress_id}' not found"
            next
          end

          test_run_case = @test_run.test_run_cases.find_by(test_case_id: test_case.id)

          # Auto-add to test run if not already part of it
          if test_run_case.nil?
            test_run_case = @test_run.test_run_cases.create(test_case: test_case, status: :untested)
          end

          unless test_run_case&.persisted?
            summary[:not_found] += 1
            summary[:errors] << "Failed to add TestCase '#{cypress_id}' to test run"
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

      # Creează un TestCase nou pentru cypress_id
      def create_test_case(cypress_id, title)
        # Normalizează cypress_id
        normalized_id = cypress_id.to_s.strip.upcase.gsub(/^TC[\s\-]+/i, 'TC')

        # Găsește sau creează un scope default pentru Cypress
        test_suite = @test_run.project.test_suites.first
        return nil unless test_suite

        scope = test_suite.test_scopes.find_or_create_by(name: 'Cypress Tests', parent_id: nil)

        # Creează test case-ul
        test_case = scope.test_cases.create(
          cypress_id: normalized_id,
          title: title.presence || "Test #{normalized_id}",
          steps: 'Automated Cypress test',
          expected_result: 'Test passes'
        )

        test_case.persisted? ? test_case : nil
      end

      # Caută TestCase încercând mai multe formate de cypress_id
      # Cypress trimite: TC-0710, TC1, TC600, TC285A
      # DB poate avea: TC0710, TC001, 600, TC285a
      def find_test_case_by_cypress_id(cypress_id)
        return nil if cypress_id.blank?

        # Normalizează: elimină cratima din TC-XXXX -> TCXXXX
        normalized_id = cypress_id.to_s.strip.upcase.gsub(/^TC[\s\-]+/i, 'TC')

        # 1. Încercăm match exact cu ID-ul normalizat
        test_case = TestCase.find_by(cypress_id: normalized_id)
        return test_case if test_case

        # 2. Încercăm match exact cu ID-ul original
        test_case = TestCase.find_by(cypress_id: cypress_id)
        return test_case if test_case

        # 3. Încercăm fără prefix TC (TC600 -> 600)
        if normalized_id.match?(/^TC/i)
          without_prefix = normalized_id.sub(/^TC/i, '')
          test_case = TestCase.find_by(cypress_id: without_prefix)
          return test_case if test_case
        end

        # 4. Încercăm cu/fără leading zeros (TC0710 -> TC710, TC1 -> TC001)
        if normalized_id.match?(/^TC(\d+)$/i)
          number = normalized_id.match(/^TC(\d+)$/i)[1]
          # Încearcă fără leading zeros
          test_case = TestCase.find_by(cypress_id: "TC#{number.to_i}")
          return test_case if test_case
          # Încearcă cu diferite padding-uri
          [4, 3, 2].each do |padding|
            padded = "TC#{number.to_i.to_s.rjust(padding, '0')}"
            test_case = TestCase.find_by(cypress_id: padded)
            return test_case if test_case
          end
        end

        # 5. Încercăm case insensitive pentru litere (TC285A -> TC285a)
        test_case = TestCase.where('LOWER(cypress_id) = LOWER(?)', normalized_id).first
        return test_case if test_case

        nil
      end
    end
  end
end
