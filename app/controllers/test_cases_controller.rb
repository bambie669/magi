# app/controllers/test_cases_controller.rb
class TestCasesController < ApplicationController
    before_action :set_test_suite, only: [:new, :create]
    before_action :set_test_case, only: [:show, :edit, :update, :destroy]
  
    # GET /test_cases/:id
    def show
      authorize @test_case
      # Load test execution history
      @execution_history = TestRunCase
        .includes(test_run: :user)
        .where(test_case: @test_case)
        .order(updated_at: :desc)
        .limit(20)
    end
  
    # GET /test_suites/:test_suite_id/test_cases/new
    def new
      @test_case = TestCase.new # Inițializează un nou TestCase
      # Pregătește lista de TestScope-uri disponibile pentru formular
      @available_test_scopes = @test_suite.root_test_scopes.flat_map do |root_scope|
        [root_scope] + root_scope.all_descendant_scopes
      end
      authorize @test_case
    end
  
    # POST /test_suites/:test_suite_id/test_cases
    def create
      selected_test_scope_id = test_case_params[:test_scope_id]

      if selected_test_scope_id.blank?
        @test_case = TestCase.new(test_case_params.except(:test_scope_id)) # Build without scope_id for error display
        @test_case.errors.add(:test_scope_id, "must be selected")
      else
        # Găsește TestScope-ul și asigură-te că aparține suitei curente
        @test_scope = TestScope.find_by(id: selected_test_scope_id, test_suite_id: @test_suite.id)

        if @test_scope
          @test_case = @test_scope.test_cases.new(test_case_params.except(:test_scope_id))
        else
          @test_case = TestCase.new(test_case_params.except(:test_scope_id)) # Build without scope_id for error display
          @test_case.errors.add(:test_scope_id, "is invalid or does not belong to this test suite.")
        end
      end

      authorize @test_case # Verifică politica pentru TestCase

      # Verifică dacă @test_case a fost initializat corect și nu are erori de la căutarea scope-ului
      if @test_case.errors.empty? && @test_case.save
         redirect_to test_suite_path(@test_suite), notice: 'Test case was successfully created.'
      else
        # Repopulează @available_test_scopes pentru re-afișarea formularului
        @available_test_scopes = @test_suite.root_test_scopes.flat_map do |root_scope|
          [root_scope] + root_scope.all_descendant_scopes
        end
        render :new, status: :unprocessable_entity
      end
    end

    # ... restul metodelor ...
  
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
      params.require(:test_case).permit(:title, :preconditions, :steps, :expected_result, :test_scope_id, :cypress_id)
    end
  end