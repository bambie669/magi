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
    @test_run_cases = @test_run.test_run_cases.includes(:test_case, :executor, attachments_attachments: :blob).order('test_cases.title ASC')
  end

  # GET /projects/:project_id/test_runs/new
  def new
    @test_run = @project.test_runs.new
    authorize @test_run
    # Permite selectarea Test Suite-urilor sau cazurilor
    @test_suites = @project.test_suites.includes(:test_cases).order(:name)
    # Sau @test_cases = @project.test_cases.order(:title)
  end

  # POST /projects/:project_id/test_runs
  def create
    @test_run = @project.test_runs.new(test_run_params)
    @test_run.user = current_user # Creatorul
    authorize @test_run

    # Selectează Test Case-urile bazat pe input (ex: un Test Suite întreg)
    selected_suite_id = params[:test_run][:test_suite_id] # Presupunem un select în form
    test_case_ids = []
    if selected_suite_id.present?
      test_suite = @project.test_suites.find(selected_suite_id)
      test_case_ids = test_suite.test_case_ids if test_suite
      @test_run.name ||= "Run for #{test_suite.name} - #{Time.zone.now.strftime('%Y-%m-%d')}" # Nume default
    else
      # Poți implementa selecție de cazuri individuale sau toate cazurile din proiect
      # test_case_ids = @project.test_case_ids
      # @test_run.name ||= "Run for All Cases - #{Time.zone.now.strftime('%Y-%m-%d')}"
    end

    if test_case_ids.empty?
       @test_suites = @project.test_suites.includes(:test_cases).order(:name) # Re-populează pentru form
       flash.now[:alert] = "Please select a Test Suite or ensure the suite has Test Cases."
       render :new, status: :unprocessable_entity
       return
    end


    if @test_run.save
       # Adaugă TestRunCases după salvarea TestRun-ului
       @test_run.add_test_cases(test_case_ids)
      redirect_to @test_run, notice: 'Test run was successfully created.'
    else
       @test_suites = @project.test_suites.includes(:test_cases).order(:name) # Re-populează pentru form
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
    params.require(:test_run).permit(:name) # Doar numele poate fi editat direct aici
  end
end