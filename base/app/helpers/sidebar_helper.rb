module SidebarHelper
  include SocialStream::Views::Sidebar

  def sidebar type = nil
    '<aside id="sidebar"><div id="sidebarContent">'.html_safe +
    sidebar_items(type).inject(ActiveSupport::SafeBuffer.new){ |result, item|
      result + item[:html]
    } +
    '</div></aside>'.html_safe
  end
end
