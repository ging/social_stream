module SocialStream
  module ToolbarConfig
    module Events
      def profile_toolbar_items(subject = current_subject)
        items = super

        if SocialStream.activity_forms.include?(:event) &&
           subject.is_a?(Event) &&
           subject.agenda.present?

           items.insert(1, {
             :key => :outline_info,
             :name => image_tag("btn/btn_outline.png")+t('menu.outline'),
             :url =>  agenda_path(subject)
           })
        end

        items
      end
    end
  end
end
