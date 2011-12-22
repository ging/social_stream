module SidebarHelper
  include SocialStream::Views::Sidebar

  def sidebar type = nil
    content_for :sidebar,
                sidebar_items(type).inject(ActiveSupport::SafeBuffer.new){ |result, item|
      result + item[:html]
    }
  end
end
