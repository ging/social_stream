# The toolbar is the left-side bar in Social Stream's layout
#
module ToolbarHelper
  # Configuration of toolbar items
  include SocialStream::Views::Toolbar

  # This method define the toolbar content for your view. The toolbar is at the left
  # side of the screen in vanilla SocialStream distribution.
  #
  # The {type} argument chooses diffent configurations. There are three build-in cases:
  # * :home, render the home menu
  # * :profile, render the profile menu for the {SocialStream::Models::Subject subject}
  #   this {type} needs a :subject {option} with the subject in the sidebar
  # * :messages, render the messages menu
  #
  # Autoexpand a menu section on your view:
  #
  # Toolbar allows you to autoexpand certain menu section that may be of interest for your view.
  # For example, the messages menu when you are looking your inbox. This is done through :option element.
  #
  # To get it working, you should use the proper :option to be expanded. For instance,
  # ":options => :contacts" it will try to expand "#contacts_menu".
  #
  # Examples:
  #
  # Render the home toolbar:
  #
  #   <% toolbar %>
  #
  # or
  #
  #   <% toolbar :home %>
  #
  # Render the profile toolbar for a user:
  #
  #   <% toolbar :profile, :subject => @user %>
  #
  # Render the messages menu:
  #
  #   <% toolbar :messages %>
  #
  # Render the profile toolbar for group changing the contacts menu option:
  #
  #   <% toolbar :profile, :subject => @group, :option => :contacts %>
  #
  def toolbar(type = :home, options = {})
    content = toolbar_items(type, options).inject(ActiveSupport::SafeBuffer.new){ |result, item|
      result + item[:html]
    }

    case request.format
    when Mime::JS
      response = <<-EOJ
        $('#toolbarContent').html("#{ escape_javascript(content) }");
        SocialStream.Toolbar.init({ option: '#{ options[:option] }' });
      EOJ

      response.html_safe
    else
      content_for(:toolbar) do
        content
      end

      content_for(:javascript) do
      <<-EOJ
        SocialStream.Toolbar.init({ option: '#{ options[:option] }' });
      EOJ
      end
    end
  end

  def toolbar_menu(type, options = {})
    ActiveSupport::SafeBuffer.new.tap do |menu|
      menu << '<div class="toolbar_menu">'.html_safe

      toolbar_menu_render(toolbar_menu_items(type, options), menu)

      menu << '</div>'.html_safe
    end
  end

  def toolbar_menu_render(items, menu)
    menu << '<ul>'.html_safe
    items.each do |item|
      menu << '<li>'.html_safe

      menu << item[:html]
      if item[:items].present?
        toolbar_menu_render(item[:items], menu)
      end

      menu << '</li>'.html_safe
    end
    menu << '</ul>'.html_safe
  end
end
