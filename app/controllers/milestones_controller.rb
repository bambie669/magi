
class MilestonesController < ApplicationController
    before_action :set_project, only: [:new, :create]
    before_action :set_milestone, only: [:show, :edit, :update, :destroy]
  
    # Nu avem index separat, milestones sunt afișate în pagina proiectului
  
    # GET /projects/:project_id/milestones/new
    def new
      @milestone = @project.milestones.new
      authorize @milestone # Verifică dacă userul poate crea milestone pt @project
    end
  
    # POST /projects/:project_id/milestones
    def create
      @milestone = @project.milestones.new(milestone_params)
      authorize @milestone # Verifică permisiunea de creare
  
      if @milestone.save
        redirect_to project_path(@project), notice: 'Milestone was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
    # GET /milestones/:id
    def show
      authorize @milestone # Pundit check
    end

    # GET /milestones/:id/edit
    def edit
      authorize @milestone # Verifică permisiunea de editare
    end
  
    # PATCH/PUT /milestones/:id
    def update
      authorize @milestone # Verifică permisiunea de update
  
      if @milestone.update(milestone_params)
        # Redirect înapoi la proiectul părintelui milestone-ului
        redirect_to project_path(@milestone.project), notice: 'Milestone was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    # DELETE /milestones/:id
    def destroy
      project = @milestone.project # Salvăm proiectul pentru redirect
      authorize @milestone # Verifică permisiunea de ștergere
      @milestone.destroy
      redirect_to project_path(project), notice: 'Milestone was successfully destroyed.', status: :see_other
    end
  
    private
  
    def set_project
      @project = Project.find(params[:project_id])
    end
  
    def set_milestone
      @milestone = Milestone.find(params[:id])
      # Poți opțional să încarci și proiectul aici dacă politica are nevoie de el
      # @project = @milestone.project
    end
  
    def milestone_params
      params.require(:milestone).permit(:name, :due_date)
    end
  end