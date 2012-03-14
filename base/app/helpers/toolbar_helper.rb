module ToolbarHelper
  # Configuration of toolbar items
  include SocialStream::Views::Toolbar

  # Define the toolbar content for your view. There are two typical cases, depending on the value of
  # options[:profile]
  # * If present, render the profile menu for the {SocialStream::Models::Subject subject}
  # * If blank, render the home menu
  #
  # The menu option allows overwriting a menu slot with the content of the given block
  #
  #
  # Autoexpanding a menu section on your view:
  #
  # Toolbar allows you to autoexpand certain menu section that may be of interest for your view.
  # For example, the messages menu when you are looking your inbox. This is done through :option element.
  #
  # To get it working, you should use the proper :option to be expanded, ":option => :messages" in the
  # mentioned example. This will try
      # Base toolbar items, automatically, to expand the section of the menu where its root
  # list link, the one expanding the section, has an id equal to "#messages_menu". If you use
  # ":options => :contacts" it will try to expand "#contacts_menu".
  #
  # For now its working with :option => :messages, :contacts or :groups
  #
  #
  # Examples:
  #
  # Render the home toolbar:
  #
  #   <% toolbar %>
  #
  # Render the profile toolbar for a user:
  #
  #   <% toolbar :profile => @user %>
  #
  # Render the home toolbar changing the messages menu option:
  #
  #   <% toolbar :option => :messages %>
  #
  # Render the profile toolbar for group changing the contacts menu option:
  #
  #   <% toolbar :profile => @group, :option => :contacts %>
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
