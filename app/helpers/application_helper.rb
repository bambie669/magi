module ApplicationHelper
  include Pagy::Frontend

  def light_theme?
    user_signed_in? && current_user.theme == 'light'
  end

  def theme_class(light_class, dark_class)
    light_theme? ? light_class : dark_class
  end

  def nav_link_classes(active:)
    if active
      'nav-link-active'
    else
      'nav-link'
    end
  end

  def status_badge_class(status)
    case status.to_s
    when 'passed', 'nominal'
      'status-nominal'
    when 'failed', 'breach'
      'status-breach'
    when 'blocked', 'caution'
      'status-caution'
    else
      'status-standby'
    end
  end

  def status_label(status)
    case status.to_s
    when 'passed' then 'Passed'
    when 'failed' then 'Failed'
    when 'blocked' then 'Blocked'
    when 'untested' then 'Not Run'
    else status.to_s.titleize
    end
  end
end
