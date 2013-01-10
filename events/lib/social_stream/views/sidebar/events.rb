module SocialStream
  module Views
    module Sidebar
      module Events
        def sidebar_items type
          super.tap do |items|
            if profile_or_current_subject
              items.unshift :key => 'calendar',
                            :html => render(:partial => 'sidebar/calendar')
            end
          end
        end
      end
    end
  end
end

