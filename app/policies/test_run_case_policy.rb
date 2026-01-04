class TestRunCasePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.manager? || user.tester?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def update?
    user.present?
  end

  def edit?
    update?
  end
end
