module LayoutsHelper
  def current_header_icon_class type
    current_header_icon?(type) ? 'active' : ''
  end

  def current_header_icon? type
    controllers =
      case type
      when :home
        'home'
      when :contacts
        'contacts'
      when :events
        'events'
      when :resources
        'repositories'
      when :messages
        [ 'messages', 'conversations' ]
      end

    Array.wrap(controllers).include? controller.controller_name
  end

  # Sets "out" class to header_signed_out in frontpage and devise's controllers
  # and "in" class in the rest of the application
  def header_logo_class
    controller.controller_path =~ /frontpage|devise/ ?
      'out' :
      'in'
  end
end
