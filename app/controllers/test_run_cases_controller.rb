class TestRunCasesController < ApplicationController
  before_action :set_test_run_case

  # PATCH/PUT /test_run_cases/:id
  def update
    # Găsește TestRun-ul părinte pentru a verifica autorizarea pe el
    test_run = @test_run_case.test_run
    # Folosește politica TestRun pentru a autoriza modificarea cazurilor din el
    # Poți adăuga o metodă specifică `update_case?` în TestRunPolicy dacă vrei control fin
    authorize test_run, :update? # Sau :update_case?

    # Atribuie executorul DOAR dacă statusul se schimbă din 'untested'
    # și dacă nu a fost deja setat
    if @test_run_case.status_was == 'untested' && test_run_case_params[:status] != 'untested' && @test_run_case.user_id.nil?
      params[:test_run_case][:user_id] = current_user.id
    elsif test_run_case_params[:status] == 'untested'
      # Reset executor if status goes back to untested
      params[:test_run_case][:user_id] = nil
    else
      # Nu modifica executorul dacă este deja setat și statusul se schimbă între passed/failed/blocked
      params[:test_run_case].delete(:user_id) unless params[:test_run_case][:user_id].blank? # Previne setarea explicită la nil
    end


    if @test_run_case.update(test_run_case_params)
      respond_to do |format|
        format.html { redirect_to test_run_path(test_run), notice: 'Test case result updated.' }
        # format.turbo_stream # Pentru update-uri dinamice cu Turbo
        format.json { render json: { status: 'success', test_run_case: @test_run_case.as_json(include: :executor) }, status: :ok }
      end
    else
       respond_to do |format|
        format.html { redirect_to test_run_path(test_run), alert: "Failed to update test case: #{@test_run_case.errors.full_messages.join(', ')}" }
        format.json { render json: { status: 'error', errors: @test_run_case.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_test_run_case
    @test_run_case = TestRunCase.find(params[:id])
  end

  def test_run_case_params
    # Permite actualizarea statusului, comentariilor și atașamentelor
    # user_id este setat intern, nu direct din parametri nesiguri
    params.require(:test_run_case).permit(:status, :comments, attachments: [])
  end
end