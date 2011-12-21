module SocialStream
  module Views
    module Settings
      module Events
        def settings_items
          super.tap do |items|
            if current_subject.is_a?(Group)
              items.insert_before 'notifications', {
                :key  => 'rooms',
                :html => render(:partial => 'rooms/settings')
              }
            end
          end
        end
      end
    end
  end
end
