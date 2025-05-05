class DashboardPolicy < ApplicationPolicy
    # Presupunem că orice utilizator logat poate vedea dashboard-ul
    def index?
      user.present?
    end
  
    # Nu există record specific, deci nu avem nevoie de Scope sau alte acțiuni
  end