module SocialStream
  module Ostatus
    module Models
      module Activity
        extend ActiveSupport::Concern

        included do
          after_commit :send_salmon
        end

        private

        # Send Salmon notification to remote subject
        def send_salmon
          return if sender.subject_type == "RemoteSubject" ||
                      receiver.subject_type != "RemoteSubject"

          entry =
            Proudhon::Entry.new id: "tag:#{ SocialStream::Ostatus.activity_feed_host },2005:activity-#{ id }",
                                title: stream_title,
                                content: stream_content,
                                verb: verb,
                                author: Proudhon::Author.new(name: sender.name,
                                                             uri: sender.webfinger_id)
          salmon = entry.to_salmon

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
