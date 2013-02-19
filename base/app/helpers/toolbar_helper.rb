# The toolbar is the left-side bar in Social Stream's layout
#
module ToolbarHelper
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
    content =
      render partial: "toolbar/#{ type }",
             locals:  options

    toolbar_init = "SocialStream.Toolbar.init({ option: '#{ options[:option] }' });".html_safe

    case request.format
    when Mime::JS
      response = 
        "$('#toolbarContent').html(\"#{ escape_javascript(content) }\");\n" +
        toolbar_init

      response.html_safe
    else
      content_for(:toolbar) do
        content
      end

      content_for :javascript, toolbar_init
    end
  end
end
