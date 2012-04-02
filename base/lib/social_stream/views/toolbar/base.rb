module SocialStream
  module Views
    module Toolbar
      module Base
        def toolbar_items type, options = {}
          SocialStream::Views::List.new.tap do |items|
            case type
            when :home, :messages
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
                :html => link_to(image_tag("btn/btn_friend.png")+t('contact.other'), "#", :id => 'toolbar_menu-contacts'),
                :items => [
                  {
                    :key => :current,
                    :html => link_to(image_tag("btn/btn_friend.png")+t('contact.current'), contacts_path)
                  },
                  {
                    :key => :contacts_graph,
                    :html => link_to(image_tag("btn/btn_friend.png")+t('contact.graph.one'), ties_path)
                  },
                  {
                    :key => :pending,
                    :html => link_to(image_tag("btn/btn_friend.png")+t('contact.pending.other'), pending_contacts_path)
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
                :html => link_to(image_tag("btn/btn_edit.png")+t('menu.information'), [subject, :profile])
              }

              if subject != current_subject
                #Like button
                items << {
                  :key => :like_button,
                  :html => link_to(link_like_params(subject)[0],
                                   link_like_params(subject)[1],
                                   :id => link_like_params(subject)[2])
                }

                if user_signed_in?
                  #Relation button
                  items << {
                    :key => :subject_relation,
                    :html => link_to(image_tag("btn/btn_friend.png") + current_subject.contact_to!(subject).status,
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
                :html => link_to(image_tag("btn/message_new.png")+ t('message.new'),
                                 new_message_path,
                                 :remote=> false)
              }

              items << {
                :key => :message_inbox,
                :html => link_to(image_tag("btn/message_inbox.png")+t('message.inbox')+' (' + current_subject.unread_messages_count.to_s + ')',
                                 conversations_path,
                                 :remote=> false)
              }

              items << {
                :key => :message_sentbox,
                :html => link_to(image_tag("btn/message_sentbox.png")+t('message.sentbox'),
                                 conversations_path(:box => :sentbox),
                                 :remote=> false)
              }

              items << {
                :key => :message_trash,
                :html => link_to(image_tag("btn/message_trash.png")+t('message.trash'),
                                 conversations_path(:box => :trash))
              }
            end
          end
        end
      end
    end
  end
end
