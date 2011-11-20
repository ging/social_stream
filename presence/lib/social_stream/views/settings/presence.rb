module SocialStream
  module Views
    module Settings
      module Presence
        def settings_items
          super.tap do |items|
            if SocialStream::Presence.enable
              if current_subject == current_user
                position = items.index{ |i| i[:key] == 'notifications' } + 1

                items.insert position, {
                  :key  => 'chat',
                  :html => render(:partial => "chat/settings")
                }
              end
            end
          end
        end
      end
    end
  end
end
