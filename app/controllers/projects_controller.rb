class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  def index
    # Folosește Pundit Scope pentru a filtra proiectele vizibile
    projects = policy_scope(Project).order(created_at: :desc)
    @pagy, @projects = pagy(projects, items: 12)
    authorize Project # Verifică dacă utilizatorul are voie să acceseze index-ul
  end

  # GET /projects/1
  def show
    authorize @project # Verifică permisiunea pentru show
    # Eager load pentru performanță
    @project = Project.includes(:milestones, { test_runs: :user }).find(params[:id])

    @milestones = @project.milestones.order(due_date: :asc)

    test_suites = @project.test_suites
                          .left_joins(:test_cases)
                          .select('test_suites.*, COUNT(test_cases.id) as test_cases_count')
                          .group('test_suites.id')
                          .order(:name)
    @pagy_suites, @test_suites = pagy(test_suites, items: 10, page_param: :suites_page)

    test_runs = @project.test_runs.order(created_at: :desc)
    @pagy_runs, @test_runs = pagy(test_runs, items: 10, page_param: :runs_page)
  end

  # GET /projects/new
  def new
    @project = Project.new
    authorize @project
  end

  # GET /projects/1/edit
  def edit
    authorize @project
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.user = current_user # Asociază creatorul
    authorize @project

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  def update
    authorize @project
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1
  def destroy
    authorize @project
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.', status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :description)
    end
end