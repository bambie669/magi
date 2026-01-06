
class TestSuitesController < ApplicationController
    before_action :set_project, only: [:new, :create]
    before_action :set_test_suite, only: [:show, :edit, :update, :destroy, :export_csv, :export_pdf, :import_csv, :process_import_csv, :csv_template, :bulk_destroy_cases, :bulk_export_cases]

    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  
    # GET /test_suites/:id
    def show
      authorize @test_suite
      # Eager load test cases pentru afișare cu paginare
      all_test_cases = @test_suite.all_test_cases.sort_by(&:title)
      @pagy, @test_cases = pagy_array(all_test_cases, items: 15)
    end
  
    # GET /projects/:project_id/test_suites/new
    def new
      @test_suite = @project.test_suites.new
      authorize @test_suite
    end
  
    # POST /projects/:project_id/test_suites
    def create
      @test_suite = @project.test_suites.new(test_suite_params)
      authorize @test_suite
  
      if @test_suite.save
        redirect_to project_path(@project), notice: 'Test suite was successfully created.'
        # Sau redirect_to @test_suite dacă vrei să mergi direct la pagina suitei
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    # GET /test_suites/:id/edit
    def edit
      authorize @test_suite
    end
  
    # PATCH/PUT /test_suites/:id
    def update
      authorize @test_suite
      if @test_suite.update(test_suite_params)
        redirect_to test_suite_path(@test_suite), notice: 'Test suite was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    # DELETE /test_suites/:id
    def destroy
      project = @test_suite.project # Salvăm proiectul pentru redirect
      authorize @test_suite
      @test_suite.destroy
      redirect_to project_path(project), notice: 'Test suite was successfully destroyed.', status: :see_other
    end

    # GET /test_suites/:id/export_csv
    def export_csv
      authorize @test_suite
      csv_data = TestCasesCsvExporter.new(@test_suite).to_csv

      send_data csv_data,
        filename: "#{@test_suite.name.parameterize}-test-cases-#{Date.current}.csv",
        type: 'text/csv; charset=utf-8'
    end

    # GET /test_suites/:id/export_pdf
    def export_pdf
      authorize @test_suite
      pdf_data = TestCasesPdfExporter.new(@test_suite).to_pdf

      send_data pdf_data,
        filename: "#{@test_suite.name.parameterize}-protocols-#{Date.current}.pdf",
        type: 'application/pdf',
        disposition: 'attachment'
    end

    # GET /test_suites/:id/csv_template
    def csv_template
      authorize @test_suite
      csv_data = TestCasesCsvExporter.headers_only

      send_data csv_data,
        filename: "test-cases-template.csv",
        type: 'text/csv; charset=utf-8'
    end

    # GET /test_suites/:id/import_csv
    def import_csv
      authorize @test_suite
    end

    # POST /test_suites/:id/process_import_csv
    def process_import_csv
      authorize @test_suite

      csv_files = params[:csv_files].presence || [params[:csv_file]].compact

      if csv_files.empty?
        redirect_to import_csv_test_suite_path(@test_suite), alert: 'Please select at least one CSV file.'
        return
      end

      total_imported = 0
      total_duplicates = 0
      all_errors = []

      csv_files.each do |csv_file|
        result = TestCasesCsvImporter.new(@test_suite, csv_file).import
        total_imported += result[:imported]
        total_duplicates += result[:duplicates]

        if result[:errors].any?
          all_errors << "#{csv_file.original_filename}:"
          all_errors.concat(result[:errors].map { |e| "  #{e}" })
        end
      end

      if all_errors.empty?
        message = "Successfully imported #{total_imported} test cases from #{csv_files.size} file(s)."
        message += " #{total_duplicates} duplicate(s) skipped." if total_duplicates > 0
        redirect_to test_suite_path(@test_suite), notice: message
      else
        flash.now[:alert] = "Import completed with errors. #{total_imported} test cases imported. #{total_duplicates} duplicate(s) skipped."
        @errors = all_errors
        @imported_count = total_imported
        @duplicate_count = total_duplicates
        render :import_csv, status: :unprocessable_entity
      end
    end

    # DELETE /test_suites/:id/bulk_destroy_cases
    def bulk_destroy_cases
      authorize @test_suite, :destroy?

      ids = params[:ids] || []
      return head :bad_request if ids.empty?

      # Only destroy test cases that belong to this test suite
      test_cases = @test_suite.test_cases.where(id: ids)
      destroyed_count = test_cases.destroy_all.count

      respond_to do |format|
        format.json { render json: { destroyed: destroyed_count }, status: :ok }
        format.html { redirect_to test_suite_path(@test_suite), notice: "#{destroyed_count} protocol(s) terminated." }
      end
    end

    # POST /test_suites/:id/bulk_export_cases
    def bulk_export_cases
      authorize @test_suite, :export_csv?

      ids = params[:ids] || []
      return head :bad_request if ids.empty?

      # Only export test cases that belong to this test suite
      test_cases = @test_suite.all_test_cases.where(id: ids).order(:title)

      csv_data = CSV.generate(headers: true) do |csv|
        csv << %w[title preconditions steps expected_result cypress_id]
        test_cases.each do |tc|
          csv << [tc.title, tc.preconditions, tc.steps, tc.expected_result, tc.cypress_id]
        end
      end

      send_data csv_data,
        filename: "#{@test_suite.name.parameterize}-selected-#{Date.current}.csv",
        type: 'text/csv; charset=utf-8'
    end

    private
  
    def set_project
      @project = Project.find(params[:project_id])
    end
  
    def set_test_suite
      @test_suite = TestSuite.includes(:project).find(params[:id]) # Include project pentru acces facil
    end
  
    def test_suite_params
      params.require(:test_suite).permit(:name, :description)
    end

    def handle_not_found
      redirect_to root_path, alert: 'Test suite was not found. It may have been deleted.'
    end
  end