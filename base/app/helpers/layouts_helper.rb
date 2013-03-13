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
        'documents'
      when :messages
        [ 'messages', 'conversations' ]
      end

    Array.wrap(controllers).include? controller.controller_name
  end
end
