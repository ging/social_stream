module SocialStream
  module Ostatus
    module ActivityStreams
      # Parses the body from a {PshbController#index} and dispatches
      # entries for parsing to {#record_from_entry!}
      def from_pshb_callback(body)
        atom = Proudhon::Atom.parse body

        atom.entries.each do |entry|
          # FIXME: get author from feed
          # https://github.com/shf/proudhon/issues/8
          entry.author.uri ||= feed.author.uri

          activity_from_entry! entry
        end
      end

      # Parses an activity form a PuSH or Salmon notification
      # Decides what action should be taken from an ActivityStreams entry
      def activity_from_entry! entry, receiver = nil
        # FIXME: should not use to_sym
        # https://github.com/shf/proudhon/issues/7
        case entry.verb.to_sym
        when :follow
          Tie.from_entry! entry, receiver
        else
          # :post is the default verb
          r = record_from_entry! entry, receiver
          r.post_activity
        end
      end

      # Redirects parsing to the suitable SocialStream's model
      def record_from_entry! entry, receiver
        model!(entry.objtype).from_entry! entry, receiver
      end

      # Finds or creates a {RemoteSubject} from an ActivityStreams entry
      #
      def actor_from_entry! entry
        webfinger_id = entry.author.uri

        if webfinger_id.blank?
          raise "Entry author without uri: #{ entry.to_xml }"
        end

        RemoteSubject.find_or_create_by_webfinger_uri! webfinger_id
      end

      # Parses the body from a {Salmon#index} and receiving actor
      def from_salmon_callback(body, receiver)
        salmon = Proudhon::Salmon.new body

        validate_salmon salmon

        activity_from_entry! salmon.to_entry, receiver
      end

      def validate_salmon salmon
        remote_subject = RemoteSubject.find_or_create_by_webfinger_uri!(salmon.to_entry.author.uri)
        key = remote_subject.rsa_key

        unless salmon.verify(key)
          raise "Invalid salmon: #{ salmon }"
        end
      end
    end
  end
end
