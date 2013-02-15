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
                :html => render(:partial => 'toolbar/contacts', :locals => { :subject => subject })
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

              # Groups
              items << {
                :key  => :groups,
                :html => link_to(image_tag("btn/btn_group.png") + t('group.other'), '#', :id => "toolbar_menu-groups", :class => "btn-blue"),
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
                :html => render(:partial => 'toolbar/info-button', :locals => { :subject => subject })
              }

              if subject != current_subject
                if user_signed_in?
                  #Relation button
                  items << {
                    :key => :subject_relation,
                    :html => render(:partial => 'toolbar/add-contact', :locals => { :subject => subject })
                  }

                  #Send message button
                  items << {
                    :key => :send_message,
                    :html => render(:partial => 'toolbar/send-message', :locals => { :subject => subject })
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
