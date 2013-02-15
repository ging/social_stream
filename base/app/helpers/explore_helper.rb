module ExploreHelper
  def current_explore_section? s
    case s
    when 'explore'
      params[:section].blank? && controller.controller_name == 'explore'
    when 'search'
      controller.controller_name == 'search'
    else 
      s == params[:section]
    end
  end

  def explore_button_class btn
    current_explore_section?(btn) ? 'active' : ''
  end
end
