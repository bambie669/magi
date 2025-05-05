# app/controllers/test_cases_controller.rb
class TestCasesController < ApplicationController
    before_action :set_test_suite, only: [:new, :create]
    before_action :set_test_case, only: [:show, :edit, :update, :destroy]
  
    # GET /test_cases/:id
    def show
      authorize @test_case
      # Test case details are usually simple enough not to need extra loading here
    end
  
    # GET /test_suites/:test_suite_id/test_cases/new
    def new
      @test_case = @test_suite.test_cases.new
      authorize @test_case
    end
  
    # POST /test_suites/:test_suite_id/test_cases
    def create
      @test_case = @test_suite.test_cases.new(test_case_params)
      authorize @test_case
  
      if @test_case.save
        redirect_to test_suite_path(@test_suite), notice: 'Test case was successfully created.'
        # Sau redirect_to @test_case
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    # GET /test_cases/:id/edit
    def edit
      authorize @test_case
    end
  
    # PATCH/PUT /test_cases/:id
    def update
      authorize @test_case
      if @test_case.update(test_case_params)
        redirect_to test_case_path(@test_case), notice: 'Test case was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    # DELETE /test_cases/:id
    def destroy
      test_suite = @test_case.test_suite # Salvăm suita pentru redirect
      authorize @test_case
      @test_case.destroy
      redirect_to test_suite_path(test_suite), notice: 'Test case was successfully destroyed.', status: :see_other
    end
  
    private
  
    def set_test_suite
      @test_suite = TestSuite.find(params[:test_suite_id])
    end
  
    def set_test_case
      @test_case = TestCase.includes(:test_suite).find(params[:id]) # Include test_suite pentru acces facil
    end
  
    def test_case_params
      params.require(:test_case).permit(:title, :preconditions, :steps, :expected_result)
    end
  end