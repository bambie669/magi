# frozen_string_literal: true

class SystemConfigPolicy < ApplicationPolicy
  def manage_operators?
    user&.admin? || false
  end
end
