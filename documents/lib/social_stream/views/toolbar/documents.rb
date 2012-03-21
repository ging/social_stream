module SocialStream
  module Views
    module Toolbar
      module Documents
        def toolbar_menu_items type, options = {}
          super.tap do |items|
            case type
            when :home
              items << {
                :key => :documents,
                :html => link_to(image_tag("btn/btn_resource.png",:class =>"menu_icon")+t("document.title.other"),
                                 [current_subject, Document.new],
                                 :id => "toolbar_menu-documents")
              }
            when :profile
              items << {
                :key => :documents,
                :html => link_to(image_tag("btn/btn_resource.png",:class =>"menu_icon")+t("document.title.other"),
                                 [options[:subject], Document.new],
                                 :id => "toolbar_menu-documents")
              }
            end
          end
        end
      end
    end
  end
end
