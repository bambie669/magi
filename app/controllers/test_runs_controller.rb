class TestRunsController < ApplicationController
  before_action :set_project, only: [:index, :new, :create] # Contextul proiectului
  before_action :set_test_run, only: [:show, :edit, :update, :destroy]

  # GET /projects/:project_id/test_runs
  def index
    @test_runs = policy_scope(@project.test_runs).order(created_at: :desc)
    authorize TestRun # Sau authorize @project, :index_test_runs? dacă ai acțiune custom în policy
  end

  # GET /test_runs/:id
  def show
    authorize @test_run
    # Eager load pentru a afișa detaliile cazurilor și a executorilor
    @test_run_cases = @test_run.test_run_cases.includes(:test_case, :user, attachments_attachments: :blob).order('test_cases.title ASC') # Changed :executor to :user
  end

  # GET /projects/:project_id/test_runs/new
  def new
    @test_run = @project.test_runs.new
    authorize @test_run
    # Load all test cases for the project to display in the form
    @available_test_cases = @project.test_cases.order(:name)
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
       @available_test_cases = @project.test_cases.order(:title)
       render :new, status: :unprocessable_entity
       return
    end

    if @test_run.save
       # Adaugă TestRunCases după salvarea TestRun-ului
       selected_test_case_ids = params.dig(:test_run, :test_case_ids)&.reject(&:blank?) || []
       selected_test_case_ids.each do |test_case_id|
        if @project.test_case_ids.include?(test_case_id.to_i)
          @test_run.test_run_cases.create(test_case_id: test_case_id, status: :untested)
        end
      end

       # The loop above replaces the need for @test_run.add_test_cases
      redirect_to @test_run, notice: 'Test run was successfully created.'
    else
      flash.now[:alert] = @test_run.errors.full_messages.join(', ')
      # Ensure this is also set in the other failure path, using :title
      @available_test_cases = @project.test_cases.order(:title)

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

  private

  def set_project
    @project = Project.find(params[:project_id])
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