module SocialStream
  module ToolbarConfig
    module Documents
      def profile_toolbar_items(subject = current_subject)
        items = super

        items << {
          :key => :documents,
          :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+t("document.title"),
          :url => polymorphic_path([subject, Document.new]),
          :options => {:link => {:id => "documents_menu"}}
        }
      end
      
      def home_toolbar_items
        items = super

        items << {
          :key => :documents,
          :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+t("document.title"),
          :url => polymorphic_path([current_subject, Document.new]),
          :options => {:link => {:id => "documents_menu"}}
        }
      end      
    end
  end
end
