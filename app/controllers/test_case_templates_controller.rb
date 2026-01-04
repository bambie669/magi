class TestCaseTemplatesController < ApplicationController
  before_action :set_project
  before_action :set_template, only: [:show, :edit, :update, :destroy]

  # GET /projects/:project_id/test_case_templates
  def index
    authorize @project, :show?
    @templates = @project.test_case_templates.ordered
  end

  # GET /projects/:project_id/test_case_templates/:id
  def show
    authorize @project, :show?
  end

  # GET /projects/:project_id/test_case_templates/new
  def new
    authorize @project, :update?
    @template = @project.test_case_templates.build
  end

  # POST /projects/:project_id/test_case_templates
  def create
    authorize @project, :update?
    @template = @project.test_case_templates.build(template_params)
    @template.user = current_user

    if @template.save
      redirect_to project_test_case_templates_path(@project),
                  notice: 'Protocol template initialized successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /projects/:project_id/test_case_templates/:id/edit
  def edit
    authorize @project, :update?
  end

  # PATCH/PUT /projects/:project_id/test_case_templates/:id
  def update
    authorize @project, :update?

    if @template.update(template_params)
      redirect_to project_test_case_templates_path(@project),
                  notice: 'Protocol template updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:project_id/test_case_templates/:id
  def destroy
    authorize @project, :update?
    @template.destroy
    redirect_to project_test_case_templates_path(@project),
                notice: 'Protocol template terminated.'
  end

  # GET /projects/:project_id/test_case_templates/:id/apply
  # Returns template data as JSON for applying to a form
  def apply
    authorize @project, :show?
    render json: @template.to_test_case_attributes
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_template
    @template = @project.test_case_templates.find(params[:id])
  end

  def template_params
    params.require(:test_case_template).permit(:name, :description, :preconditions, :steps, :expected_result)
  end
end
