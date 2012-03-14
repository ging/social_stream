module SocialStream
  module Views
    module Toolbar
      module Presence
        def toolbar_items type, options = {}
          super.tap do |items|
            case type
            when :home, :messages
              items << {
                :key => 'chat',
                :html => render(:partial => 'chat/index' , :locals => {:flow => false }) 
              }
            when :profile
              items << {
                :key => 'chat',
                :html => render(:partial => 'chat/index',
                                :locals => {
                                   :flow => true ,
                                   :group => @group
                                 })
              }
            end
          end
        end
      end
    end
  end
end
