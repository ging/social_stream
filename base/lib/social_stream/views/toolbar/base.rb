module SocialStream
  module Views
    module Toolbar
      module Base
        def toolbar_items type, options = {}
          SocialStream::Views::List.new.tap do |items|
            case type
            when :home
              items << {
                :key => :subject,
                :html => render(:partial => 'toolbar/subject')
              }

              items << {
                :key => :menu,
                :html => toolbar_menu(type, options)
              }
            when :profile
              subject = options[:subject]
              raise "Need a subject options for profile toolbar" if subject.blank?

              items << {
                :key => :logo,
                :html => render(:partial => 'toolbar/logo', :locals => { :subject => subject })
              }

              items << {
                :key => :menu,
                :html => toolbar_menu(type, options)
              }

              items << {
                :key => :contacts,
                :html => render(:partial => 'subjects/contacts', :locals => { :subject => subject })
              }
            when :messages
              items << {
                :key => :menu,
                :html => toolbar_menu(type, options)
              }
            end
          end
        end

        def toolbar_menu_items type, options = {}
          SocialStream::Views::List.new.tap do |items|
            case type
            when :home
              #Contacts
              items << {
                :key => :contacts,
                :html => link_to(raw("<i class='icon_navbar-followers'></i> ")+t('contact.other'), "#", :id => 'toolbar_menu-contacts'),
                :items => [
                  {
                    :key => :current,
                    :html => link_to(raw("<i class='icon_navbar-followers'></i> ")+t('contact.current'), contacts_path)
                  },
                  {
                    :key => :contacts_graph,
                    :html => link_to(raw("<i class='icon_navbar-followers'></i> ")+t('contact.graph.one'), ties_path)
                  },
                  {
                    :key => :pending,
                    :html => link_to(raw("<i class='icon_navbar-followers'></i> ")+t('contact.pending.other'), pending_contacts_path)
                  },
                  {
                    :key => :invitations,
                    :html => link_to(image_tag("btn/btn_invitation.png")+t('invitation.toolbar'), new_invitation_path)
                  }
                ]
              }

              # Groups
              items << {
                :key  => :groups,
                :html => link_to(image_tag("btn/btn_group.png") + t('group.other'), '#', :id => "toolbar_menu-groups"),
                :items => [
                  {
                  :key => :new_group ,
                  :html => link_to(image_tag("btn/btn_group.png")+t('group.new.action'), new_group_path)
                  }
                ]
              }
            when :profile
              subject = options[:subject]
              raise "Need a subject options for profile toolbar" if subject.blank?

              #Information button
              items << {
                :key => :subject_info,
                :html => link_to(raw("<i class='icon_tool-info'></i>")+t('menu.information'), [subject, :profile])
              }

              if subject != current_subject
                if user_signed_in?
                  #Relation button
                  items << {
                    :key => :subject_relation,
                    :html => link_to(raw("<i class='icon_navbar-followers'></i> ") + current_subject.contact_to!(subject).status,
                                     edit_contact_path(current_subject.contact_to!(subject)))
                  }

                  #Send message button
                  items << {
                    :key => :send_message,
                    :html => link_to(image_tag("btn/btn_send.png")+t('message.send'),
                                     new_message_path(:receiver => subject.slug))
                  }
                end
              end
            when :messages
              # Messages
              items << {
                :key => :message_new,
                :html => link_to(raw("<i class='icon_message-new'></i> ")+ t('message.new'),
                                 new_message_path,
                                 :remote=> false)
              }

              items << {
                :key => :message_inbox,
                :html => link_to(raw("<i class='icon_message-inbox'></i> ")+t('message.inbox')+' (' + current_subject.unread_messages_count.to_s + ')',
                                 conversations_path,
                                 :remote=> false)
              }

              items << {
                :key => :message_sentbox,
                :html => link_to(raw("<i class='icon_message-sendbox'></i> ")+t('message.sentbox'),
                                 conversations_path(:box => :sentbox),
                                 :remote=> false)
              }

              items << {
                :key => :message_trash,
                :html => link_to(raw("<i class='icon_message-trash'></i> ")+t('message.trash'),
                                 conversations_path(:box => :trash))
              }
            end
          end
        end
      end
    end
  end
end
