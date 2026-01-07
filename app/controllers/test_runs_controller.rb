class TestRunsController < ApplicationController
  before_action :set_project, only: [:new, :create] # Contextul proiectului
  before_action :set_project_optional, only: [:index]
  before_action :set_test_run, only: [:show, :edit, :update, :destroy, :export_csv, :export_pdf]

  # GET /test_runs or GET /projects/:project_id/test_runs
  def index
    if @project
      test_runs = policy_scope(@project.test_runs)
    else
      test_runs = policy_scope(TestRun)
    end

    # Search
    if params[:q].present?
      test_runs = test_runs.where("name ILIKE ?", "%#{params[:q]}%")
    end

    # Filter by status
    if params[:status].present?
      case params[:status]
      when 'in_progress'
        test_runs = test_runs.joins(:test_run_cases).where(test_run_cases: { status: :untested }).distinct
      when 'completed'
        test_runs = test_runs.left_joins(:test_run_cases).group(:id).having("COUNT(CASE WHEN test_run_cases.status = 0 THEN 1 END) = 0")
      when 'has_failures'
        test_runs = test_runs.joins(:test_run_cases).where(test_run_cases: { status: :failed }).distinct
      end
    end

    # Sorting
    sort_column = %w[name created_at].include?(params[:sort]) ? params[:sort] : 'created_at'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    test_runs = test_runs.order("#{sort_column} #{sort_direction}")

    @pagy, @test_runs = pagy(test_runs, items: 15)
    authorize TestRun
  end

  # GET /test_runs/:id
  def show
    authorize @test_run

    # Get test run cases with eager loading
    test_run_cases = @test_run.test_run_cases.includes(:test_case, :user, attachments_attachments: :blob)

    # Filter by status
    if params[:status].present? && %w[passed failed blocked untested].include?(params[:status])
      test_run_cases = test_run_cases.where(status: params[:status])
    end

    # Search by test case title or cypress_id
    if params[:q].present?
      test_run_cases = test_run_cases.joins(:test_case).where(
        "test_cases.title ILIKE :q OR test_cases.cypress_id ILIKE :q",
        q: "%#{params[:q]}%"
      )
    end

    # Sort
    sort_column = params[:sort] || 'title'
    sort_direction = params[:direction] == 'desc' ? 'DESC' : 'ASC'

    case sort_column
    when 'status'
      test_run_cases = test_run_cases.order("test_run_cases.status #{sort_direction}")
    when 'cypress_id'
      test_run_cases = test_run_cases.joins(:test_case).order("test_cases.cypress_id #{sort_direction}")
    else
      test_run_cases = test_run_cases.joins(:test_case).order("test_cases.title #{sort_direction}")
    end

    @test_run_cases = test_run_cases
  end

  # GET /projects/:project_id/test_runs/new
  def new
    @test_run = @project.test_runs.new
    authorize @test_run
    # Load all test cases for the project to display in the form
    @available_test_cases = @project.all_project_test_cases.sort_by(&:title)
  end

  # POST /projects/:project_id/test_runs
  def create
    @test_run = @project.test_runs.new(test_run_params)
    @test_run.user = current_user # Creatorul
    authorize @test_run

    # Get the selected test case IDs directly from the form parameters
    selected_test_case_ids = params.dig(:test_run, :test_case_ids)&.reject(&:blank?) || []

    # Check if any test cases were actually selected
    if selected_test_case_ids.empty?
       flash.now[:alert] = "Please select at least one Test Case to include in the run."
       # Add this line to ensure @available_test_cases is set for the re-rendered form
       @available_test_cases = @project.all_project_test_cases.sort_by(&:title)
       render :new, status: :unprocessable_entity
       return
    end

    if @test_run.save
       # Adaugă TestRunCases după salvarea TestRun-ului
       selected_test_case_ids = params.dig(:test_run, :test_case_ids)&.reject(&:blank?) || []
       selected_test_case_ids.each do |test_case_id|
        if @project.all_project_test_cases.map(&:id).include?(test_case_id.to_i)
          @test_run.test_run_cases.create(test_case_id: test_case_id, status: :untested)
        end
      end

       # The loop above replaces the need for @test_run.add_test_cases
      redirect_to @test_run, notice: 'Test run was successfully created.'
    else
      flash.now[:alert] = @test_run.errors.full_messages.join(', ')
      # Ensure this is also set in the other failure path, using :title
      @available_test_cases = @project.all_project_test_cases.sort_by(&:title)

      render :new, status: :unprocessable_entity
    end
  end

  # GET /test_runs/:id/edit
  def edit
    authorize @test_run
  end

  # PATCH/PUT /test_runs/:id
  def update
    authorize @test_run
    if @test_run.update(test_run_params)
      redirect_to @test_run, notice: 'Test run was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /test_runs/:id
  def destroy
    authorize @test_run
    @test_run.destroy
    redirect_to project_test_runs_url(@test_run.project), notice: 'Test run was successfully destroyed.', status: :see_other
  end

  # GET /test_runs/:id/export_csv
  def export_csv
    authorize @test_run
    csv_data = TestRunCsvExporter.new(@test_run).to_csv

    send_data csv_data,
      filename: "#{@test_run.name.parameterize}-results-#{Date.current}.csv",
      type: 'text/csv; charset=utf-8'
  end

  # GET /test_runs/:id/export_pdf
  def export_pdf
    authorize @test_run
    pdf_data = TestRunPdfExporter.new(@test_run).to_pdf

    send_data pdf_data,
      filename: "#{@test_run.name.parameterize}-report-#{Date.current}.pdf",
      type: 'application/pdf',
      disposition: 'attachment'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_project_optional
    @project = Project.find(params[:project_id]) if params[:project_id].present?
  end

  def set_test_run
    # Include project pentru a verifica permisiunile mai ușor dacă e nevoie
    @test_run = TestRun.includes(:project).find(params[:id])
  end

  def test_run_params
    # Allow name and the array of test_case_ids from the checkboxes
    params.require(:test_run).permit(:name, test_case_ids: [])
  end
end