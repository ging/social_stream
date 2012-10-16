module SocialStream
  module Ostatus
    module Models
      module Contact
        extend ActiveSupport::Concern

        included do
          # FIXME: hack, this overwrites base definition, see there
          # for the reasons related to after_destroy callbacks
          alias_method_chain :unset_follow_action, :salmon
        end

        module ClassMethods
          # Find contact from OStatus entry
          def from_entry! entry, receiver
            # Sender must be remote
            sender = RemoteSubject.find_or_create_by_webfinger_uri! entry.author.uri

            contact = sender.contact_to!(receiver)

            # FIXME: hack
            contact.user_author = sender

            contact
          end
        end

        # Send Salmon notification
        #
        # FIXME DRY with activity.rb
        def unset_follow_action_with_salmon(relation)
          unset_follow_action_without_salmon(relation)

          return if sender.subject_type == "RemoteSubject" ||
                      receiver.subject_type != "RemoteSubject"

          title = I18n.t "activity.stream.title.unfollow",
                         author: sender_subject.name,
                         activity_object: receiver_subject.name

          entry =
            Proudhon::Entry.new id: "tag:#{ SocialStream::Ostatus.activity_feed_host },2005:contact-destroy-#{ id }",
                                title: title,
                                content: title,
                                verb: :unsubscribe,
                                author: Proudhon::Author.new(name: sender.name,
                                                             uri: sender.webfinger_uri)
          salmon = entry.to_salmon

          if SocialStream::Ostatus.debug_requests
            logger.info entry.to_xml
          end

          # FIXME: Rails 4 queues
          Thread.new do
            salmon.deliver receiver_subject.salmon_url, sender.rsa_key

            ActiveRecord::Base.connection.close
          end
        end
      end
    end
  end
end
