class TestSuitePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    # Definește cine poate vedea ce test suites
    def resolve
      if user.admin? || user.manager? || user.tester?
        scope.all # Adminii, managerii și testerii pot vedea toate test suites (poate fi filtrat pe proiect ulterior)
      else
        scope.none # Alți utilizatori nu văd nimic
      end
    end
  end

  # Cine poate vedea lista de test suites (index)?
  def index?
    user.present? # Orice utilizator logat
  end

  # Cine poate vedea detaliile unui test suite (show)?
  def show?
    user.present? # Orice utilizator logat (poate fi rafinat cu scope-ul dacă e necesar)
  end

  # Cine poate crea test suites?
  def create?
    user.admin? || user.manager? || user.tester? # Adminii, managerii și testerii pot crea
  end

  def new?
    create?
  end

  # Cine poate modifica un test suite?
  def update?
    user.admin? || user.manager? || user.tester? # Adminii, managerii și testerii pot modifica
  end

  def edit?
    update?
  end

  # Cine poate șterge un test suite?
  def destroy?
    user.admin? || user.manager? # Doar adminii și managerii
  end
end