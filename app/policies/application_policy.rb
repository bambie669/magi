# app/policies/application_policy.rb
class ApplicationPolicy
    attr_reader :user, :record
  
    def initialize(user, record)
      @user = user
      @record = record
    end
  
    # Definește metode comune aici, ex:
    def index?
      false # Sau o valoare default mai permisivă/restrictivă
    end
  
    def show?
      false
    end
  
    def create?
      false
    end
  
    def new?
      create?
    end
  
    def update?
      false
    end
  
    def edit?
      update?
    end
  
    def destroy?
      false
    end
  
    class Scope
      attr_reader :user, :scope
  
      def initialize(user, scope)
        @user = user
        @scope = scope
      end
  
      def resolve
        # Valoare default: nu returnează nimic dacă nu e suprascrisă
        # Sau returnează scope.all dacă vrei ca default să fie permisiv
        scope.none
        # sau
        # scope.all
      end
    end
  end