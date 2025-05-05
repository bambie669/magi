class MilestonePolicy < ApplicationPolicy
  class Scope < Scope
    # Definește cine poate vedea ce milestones
    def resolve
      if user.admin? || user.manager? || user.tester?
        scope.all # Adminii, managerii și testerii pot vedea toate milestones (poate fi filtrat pe proiect ulterior)
      else
        scope.none # Alți utilizatori nu văd nimic
      end
    end
  end

  # Cine poate vedea lista de milestones (index)?
  def index?
    user.present? # Orice utilizator logat
  end

  # Cine poate vedea detaliile unui milestone (show)?
  def show?
    user.present? # Orice utilizator logat (poate fi rafinat cu scope-ul dacă e necesar)
  end

  # Cine poate crea milestones?
  def create?
    user.admin? || user.manager? # Doar adminii și managerii
  end

  def new?
    create?
  end

  # Cine poate modifica un milestone?
  def update?
    user.admin? || user.manager? # Doar adminii și managerii (poate vrei să limitezi la managerul proiectului)
  end

  def edit?
    update?
  end

  # Cine poate șterge un milestone?
  def destroy?
    user.admin? || user.manager? # Doar adminii și managerii
  end
end