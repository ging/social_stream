module SocialStream
  module ToolbarConfig
    module Base
      # Base toolbar items
      def home_toolbar_items
        Array.new.tap do |items|
        #Contacts
          items << {
            :key => :contacts,
            :name => image_tag("btn/btn_friend.png")+t('contact.other'),
            :url => "#",
            :options => {:link => {:id => "contacts_menu"}},
            :items => [
              {:key => :invitations, :name => image_tag("btn/btn_friend.png")+t('contact.current'), :url => contacts_path},
              {:key => :contacts_graph, :name => image_tag("btn/btn_friend.png")+t('contact.graph.one'), :url => ties_path},
              {:key => :invitations, :name => image_tag("btn/btn_friend.png")+t('contact.pending.other'), :url => pending_contacts_path},
              {:key => :invitations, :name => image_tag("btn/btn_invitation.png")+t('invitation.toolbar'), :url => new_invitation_path}
            ]
          }
        end
      end

      # Builds the default profile toolbar items
      def profile_toolbar_items(subject = current_subject)
        Array.new.tap do |items|
        #Information button
          items << {
            :key => :subject_info,
            :name => image_tag("btn/btn_edit.png")+t('menu.information'),
            :url => [subject, :profile]
          }

          if subject != current_subject
            #Like button
            items << {
              :key => :like_button,
              :name => link_like_params(subject)[0],
              :url => link_like_params(subject)[1],
              :options => {:link => link_like_params(subject)[2]}
            }

            if user_signed_in?
              #Relation button
              items << {
                :key => :subject_relation,
                :name => image_tag("btn/btn_friend.png") + current_subject.contact_to!(subject).status,
                :url => edit_contact_path(current_subject.contact_to!(subject))
              }

              #Send message button
              items << {:key => :send_message,
                :name => image_tag("btn/btn_send.png")+t('message.send'),
                :url => new_message_path(:receiver => subject.slug)
              }
            end
          end
        end
      end

      def messages_toolbar_items
        Array.new.tap do |items|
        # Messages
          items << { :key => :message_new,
            :name => image_tag("btn/message_new.png")+ t('message.new'),
            :url => new_message_path,
            :options => {:link =>{:remote=> false}}}
          items << { :key => :message_inbox,
            :name => image_tag("btn/message_inbox.png")+t('message.inbox')+' (' + current_subject.mailbox.inbox(:unread => true).count.to_s + ')',
            :url => conversations_path,
            :options => {:link =>{:remote=> false}}}
          items << { :key => :message_sentbox,
            :name => image_tag("btn/message_sentbox.png")+t('message.sentbox'),
            :url => conversations_path(:box => :sentbox),
            :options => {:link =>{:remote=> false}}}
          items << { :key => :message_trash,
            :name => image_tag("btn/message_trash.png")+t('message.trash'),
            :url => conversations_path(:box => :trash)}
        end
      end
    end
  end
end

