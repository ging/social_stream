module SocialStream
  module ToolbarConfig
    module Documents
      def home_toolbar_items
        items = super

        # FIXME: insert
        items << {
          :key => :resources,
          :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+t('resource.mine'),
          :url => "#",
          :options => {:link => {:id => "resources_menu"}},
          :items => [
            {:key => :resources_documents,:name => image_tag("btn/btn_document.png")+t('document.title'),:url => documents_path},
            {:key => :resources_pictures,:name => image_tag("btn/btn_gallery.png")+t('picture.title'),:url => pictures_path},
            {:key => :resources_videos,:name => image_tag("btn/btn_video.png")+t('video.title'),:url => videos_path},
            {:key => :resources_audios,:name => image_tag("btn/btn_audio.png")+t('audio.title'),:url => audios_path}
          ]
        }
      end

      def profile_toolbar_items(subject = current_subject)
        items = super

        items << {
          :key => :resources,
          :name => image_tag("btn/btn_resource.png",:class =>"menu_icon")+t("resource.#{ subject == current_subject ? 'mine' : 'title' }"),
          :url => "#",
          :options => {:link => {:id => "resources_menu"}},
          :items => [
            {:key => :resources_documents,:name => image_tag("btn/btn_document.png")+t('document.title'),:url => polymorphic_path([subject, Document.new])},
            {:key => :resources_pictures,:name => image_tag("btn/btn_gallery.png")+t('picture.title'),:url => polymorphic_path([subject, Picture.new])},
            {:key => :resources_videos,:name => image_tag("btn/btn_video.png")+t('video.title'),:url => polymorphic_path([subject, Video.new])},
            {:key => :resources_audios,:name => image_tag("btn/btn_audio.png")+t('audio.title'),:url => polymorphic_path([subject, Audio.new])}
            ]
        }
      end
    end
  end
end
