module ToolbarHelper
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
  # mentioned example. This will try, automatically, to expand the section of the menu where its root
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
  def toolbar(options = {}, &block)
    if options[:option] && block_given?
      menu_options[options[:option]] = capture(&block)
    end

    content = capture do
      if options[:profile]
        render :partial => 'toolbar/profile', :locals => { :subject => options[:profile] }
      else
        render :partial => 'toolbar/home'
      end
    end

    case request.format
    when Mime::JS
      response = <<-EOJ

          $('#toolbar').html("#{ escape_javascript(content) }");
          initMenu();
          expandSubMenu('#{ options[:option] }');
          EOJ

      response.html_safe
    else
    content_for(:toolbar) do
    content
    end
    content_for(:javascript) do
    <<-EOJ
    expandSubMenu('#{ options[:option] }');
    EOJ
    end
    end
  end

  # Cache menu options for toolbar
  #
  # @api private
  def menu_options #:nodoc:
    @menu_options ||= {}
  end

  #Prints the home toolbar menu.
  #By default it prints the default_home_toolbar_menu, but yo can 
  #change everything in your initializer
  #
  #NOTE: To correctly show your menu in the vies we suggest using 
  #the simple_navigation list renderer o create the menu as a list
  #of links 
  # <ul>
  #   <li>
  #     <a href="url">Link</a>
  #   </li>
  # </ul>
  #
  #To use simple navigation renderer you should create an array of 
  #items like explained in the wiki of simple_navigation for ad-hoc menus
  #in https://github.com/andi/simple-navigation/wiki/Dynamic-Navigation-Items
  #and return with the expression
  # render_items items
  def home_toolbar_menu
    default_home_toolbar_menu
  end

  #Prints the home profile menu.
  #By default it prints the default_profile_toolbar_menu, but yo can 
  #change everything in your initializer
  #
  #NOTE: To correctly show your menu in the vies we suggest using 
  #the simple_navigation list renderer o create the menu as a list
  #of links 
  # <ul>
  #   <li>
  #     <a href="url">Link</a>
  #   </li>
  # </ul>
  #
  #To use simple navigation renderer you should create an array of 
  #items like explained in the wiki of simple_navigation for ad-hoc menus
  #in https://github.com/andi/simple-navigation/wiki/Dynamic-Navigation-Items
  #and return with the expression
  # render_items items
  def profile_toolbar_menu(subject=current_subject)
    default_profile_toolbar_menu(subject)
  end

  #Prints the default home toolbar menu
  def default_home_toolbar_menu
    items = Array.new
    #Notifications
    items << {:key => :notifications,
      :name => image_tag("btn/btn_notification.png")+t('notification.other')+' ('+ current_subject.mailbox.notifications.not_trashed.unread.count.to_s+')',
      :url => notifications_path,
      :options => {:link => {:id => "notifications_menu"}}}

    #Messages
    items << {:key => :messages,
      :name => image_tag("btn/new.png")+t('message.other')+' (' + current_subject.mailbox.inbox(:unread => true).count.to_s + ')',
      :url => "#",
      :options => {:link => {:id => "messages_menu"}},
      :items => [
        {:key => :message_new, :name => image_tag("btn/message_new.png")+ t('message.new'), :url => new_message_path},
        {:key => :message_inbox, :name => image_tag("btn/message_inbox.png")+t('message.inbox')+' (' + current_subject.mailbox.inbox(:unread => true).count.to_s + ')',
          :url => conversations_path, :options => {:link =>{:remote=> true}}},
        {:key => :message_sentbox, :name => image_tag("btn/message_sentbox.png")+t('message.sentbox'), :url => conversations_path(:box => :sentbox), :remote=> true},
        {:key => :message_trash, :name => image_tag("btn/message_trash.png")+t('message.trash'), :url => conversations_path(:box => :trash)}
      ]}

    #Documents if present
    if SocialStream.activity_forms.include? :document
      items << {:key => :resources,
        :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+t('resource.mine'),
        :url => "#",
        :options => {:link => {:id => "resources_menu"}},
        :items => [
          {:key => :resources_documents,:name => image_tag("btn/btn_documents.png")+t('document.title'),:url => documents_path},
          {:key => :resources_pictures,:name => image_tag("btn/btn_gallery.png")+t('picture.title'),:url => pictures_path},
          {:key => :resources_videos,:name => image_tag("btn/btn_video.png")+t('video.title'),:url => videos_path},
          {:key => :resources_audios,:name => image_tag("btn/btn_audio.png")+t('audio.title'),:url => audios_path}
        ]}
    end

    #Contacts
    relation_items = [{:key => :invitations, :name => image_tag("btn/btn_invitation.png")+t('invitation.other'), :url => new_invitation_path}]
    current_subject.relation_customs.sort.each do |r|
      relation_items << {:key => r.name + "_menu",
        :name => image_tag("btn/btn_friend.png") + r.name,
        :url => contacts_path(:relation => r.id)}
    end
    items << {:key => :contacts,
      :name => image_tag("btn/btn_friend.png")+t('contact.other'),
      :url => "#",
      :options => {:link => {:id => "contacts_menu"}},
      :items => relation_items}

    #Subjects
    items << {:key => :groups,
      :name => image_tag("btn/btn_group.png")+t('group.other'),
      :url => "#",
      :options => {:link => {:id => "groups_menu"}},
      :items => [{:key => :new_group ,:name => image_tag("btn/btn_group.png")+t('group.new.action'),:url => new_group_path('group' => { '_founder' => current_subject.slug })}]
    }

    render_items items
  end

  #Prints the default profile toolbar menu
  def default_profile_toolbar_menu(subject = current_subject)
    items = Array.new
    #Information button
    items << {:key => :subject_info,
      :name => image_tag("btn/btn_edit.png")+t('menu.information'),
      :url => [subject, :profile]
    }

    if subject!=current_subject
      #Like button
      items << {:key => :like_button,
        :name => link_like_params(subject)[0],
        :url => link_like_params(subject)[1],
        :options => {:link => link_like_params(subject)[2]}}
        
      if user_signed_in?
        #Relation button
        items << {:key => :subject_relation,
          :name => image_tag("btn/btn_friend.png") + contact_status(subject),
          :url => edit_contact_path(current_subject.contact_to!(subject))
        }
        #Send message button
        items << {:key => :send_message,
          :name => image_tag("btn/btn_send.png")+t('message.send'),
          :url => new_message_path(:receiver => subject.slug)
        }
      end
    end
    #Documents if present
    if SocialStream.activity_forms.include? :document
      if subject == current_subject
        resources_label = t('resource.mine')
      else
        resources_label = t('resource.title')        
      end
      items << {:key => :resources,
        :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+resources_label,
        :url => "#",
        :options => {:link => {:id => "resources_menu"}},
        :items => [
          {:key => :resources_documents,:name => image_tag("btn/btn_documents.png")+t('document.title'),:url => documents_path},
          {:key => :resources_pictures,:name => image_tag("btn/btn_gallery.png")+t('picture.title'),:url => pictures_path},
          {:key => :resources_videos,:name => image_tag("btn/btn_video.png")+t('video.title'),:url => videos_path},
          {:key => :resources_audios,:name => image_tag("btn/btn_audio.png")+t('audio.title'),:url => audios_path}
        ]}
    end
    render_items items
  end

  #Renders array of navigation items with simple_navigation
  def render_items(items)
    menu = render_navigation :items => items
    return raw menu
  end
end
