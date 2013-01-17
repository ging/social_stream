module ExploreHelper
  def explore_button_class btn
    active =
      case btn
      when 'index'
        params[:section].blank?
      when 'search'
        controller.controller_name == 'search'
      else 
        btn == params[:section]
      end

   active ? 'active' : ''
  end
end
