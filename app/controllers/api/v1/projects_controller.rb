module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: [:show]

      # GET /api/v1/projects
      def index
        @projects = Project.all
        render json: @projects.map { |p| project_json(p) }
      end

      # GET /api/v1/projects/:id
      def show
        authorize @project
        render json: project_json(@project, full: true)
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_json(project, full: false)
        data = {
          id: project.id,
          name: project.name,
          description: project.description,
          owner: project.user&.display_name,
          test_suites_count: project.test_suites.count,
          test_runs_count: project.test_runs.count,
          created_at: project.created_at.iso8601,
          updated_at: project.updated_at.iso8601
        }

        if full
          data[:test_suites] = project.test_suites.map do |ts|
            {
              id: ts.id,
              name: ts.name,
              description: ts.description,
              test_cases_count: ts.all_test_cases.count
            }
          end
        end

        data
      end
    end
  end
end
