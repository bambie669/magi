class ProjectPolicy < ApplicationPolicy
  # Folosim Scope pentru a filtra ce proiecte poate vedea un utilizator
  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.admin?
        scope.all # Adminii văd tot
      elsif user.manager? || user.tester? # Managerii și testerii văd tot (poți rafina ulterior)
         scope.all
        # Sau, dacă vrei să limitezi la proiectele create de ei sau la care sunt asignați (necesită model de asignare)
        # scope.where(user: user) # Exemplu simplu
      else
        scope.none # Utilizatorii neînregistrați nu văd nimic
      end
    end
  end

  def index?
    user.present? # Doar utilizatorii logați pot vedea lista
  end

  def show?
    user.present? # Toți utilizatorii logați pot vedea detalii (poate fi rafinat cu Scope)
  end

  def create?
    user.admin? || user.manager? # Doar adminii și managerii pot crea
  end

  def new?
    create?
  end

  def update?
    user.admin? || (user.manager? && record.user == user) # Admin sau managerul care l-a creat
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? # Doar adminii pot șterge
  end
end