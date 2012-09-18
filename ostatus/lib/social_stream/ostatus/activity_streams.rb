module SocialStream
  module Ostatus
    module ActivityStreams
      # Parses the body from a {PshbController#index} and dispatches
      # entries for parsing to {#record_from_entry!}
      def from_pshb_callback(body)
        atom = Proudhon::Atom.parse body

        atom.entries.each do |entry|
          activity_from_entry! entry
        end
      end

      # Parses an activity form a PuSH or Salmon notification
      # Decides what action should be taken from an ActivityStreams entry
      def activity_from_entry! entry
        case entry.verb
        when :post
          r = record_from_entry! entry
          r.post_activity
        else
          raise "Unsupported verb #{ entry.verb }"
        end
      end

      # Redirects parsing to the suitable SocialStream's model
      def record_from_entry! entry
        model!(entry.objtype).from_entry! entry
      end

      # Finds or creates a {RemoteSubject} from an ActivityStreams entry
      #
      def actor_from_entry! entry
        webfinger_id = entry.author.uri

        if webfinger_id.blank?
          raise "Entry author without uri"
        end

        RemoteSubject.find_or_create_by_webfinger_id webfinger_id
      end

      # Parses the body from a {Salmon#index}
      def from_salmon_callback(body)
        salmon = Proudhon::Salmon.new body

        entry = salmon.to_entry

        validate_salmon_entry entry

        activity_from_entry! entry
      end

      def validate_salmon_entry entry
        # TODO
        # finger = Proudhon::Finger.new author_webfinger_id
        # magic_key = Proudhon::MagicKey.new finger.links[:magic_public_key]
        # salmon.verify public_key

        true
      end
    end
  end
end
