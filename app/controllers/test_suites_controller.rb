
class TestSuitesController < ApplicationController
    before_action :set_project, only: [:new, :create]
    before_action :set_test_suite, only: [:show, :edit, :update, :destroy]
  
    # GET /test_suites/:id
    def show
      authorize @test_suite
      # Eager load test cases pentru afișare
      @test_cases = @test_suite.test_cases.order(:title)
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
  end