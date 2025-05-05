class TestCasePolicy < ApplicationPolicy
  class Scope < Scope
    # Similar cu ProjectPolicy::Scope, filtrează în funcție de rol/asignare
    def resolve
       if user.admin? || user.manager? || user.tester?
         scope.all # Toți utilizatorii logați pot vedea run-urile (poate fi filtrat pe proiect)
       else
         scope.none
       end
    end
  end

   def index?
     user.present?
   end

   def show?
     user.present? # Oricine logat poate vedea un test run
   end

   def create?
     user.admin? || user.manager? || user.tester? # Oricine logat poate crea un test run
   end

   def new?
     create?
   end

   # Permisiunea de a actualiza un TestRun este cheia pentru a actualiza TestRunCases
   def update?
     # Oricine logat poate actualiza (executa) un test run? Sau doar tester/manager?
     user.present?
   end

   def edit?
     # Editarea detaliilor run-ului (nume, etc.) poate fi limitată
     user.admin? || (user.manager? && record.user == user)
   end

   def destroy?
     user.admin? || user.manager? # Doar admin/manager poate șterge
   end

  # Adaugă o metodă specifică dacă vrei control granular pe actualizarea cazurilor
  # def update_case?
  #   user.present? # Oricine poate actualiza statusul unui caz în run
  # end
end