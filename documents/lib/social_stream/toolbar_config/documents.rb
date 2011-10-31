module SocialStream
  module ToolbarConfig
    module Documents
      def profile_toolbar_items(subject = current_subject)
        items = super

        items << {
          :key => :resources,
          :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+t("resource.title"),
          :url => polymorphic_path([subject, Document.new]),
          :options => {:link => {:id => "resources_menu"}}
        }
      end
      
      def home_toolbar_items
        items = super

        items << {
          :key => :resources,
          :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+t("resource.title"),
          :url => polymorphic_path([current_subject, Document.new]),
          :options => {:link => {:id => "resources_menu"}}
        }
      end      
    end
  end
end
