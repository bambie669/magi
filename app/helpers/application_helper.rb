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
      theme_class(
        # EVA-00: Blue with orange accent
        'bg-eva00-blue-pale text-eva00-blue-dark border-l-2 border-eva00-orange',
        # EVA-01: Purple with green accent
        'bg-eva01-purple-light/30 text-eva01-green border-l-2 border-eva01-green'
      )
    else
      theme_class(
        # EVA-00: Gray text
        'text-eva00-gray hover:bg-eva00-blue-pale/50 hover:text-eva00-blue-dark border-l-2 border-transparent',
        # EVA-01: Light text
        'text-terminal-white/70 hover:bg-eva01-purple-mid/50 hover:text-eva01-green border-l-2 border-transparent'
      )
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
    when 'passed' then 'NOMINAL'
    when 'failed' then 'BREACH'
    when 'blocked' then 'PATTERN BLUE'
    when 'untested' then 'STANDBY'
    else status.to_s.upcase
    end
  end
end
