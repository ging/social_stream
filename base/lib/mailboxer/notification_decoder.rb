module Mailboxer
  module NotificationDecoder
    include SubjectsHelper, ActionView::Helpers::TextHelper
    def decode_notification notification_text, activity
      return if activity.nil?
      notification_text = notification_text.gsub(/\%\{sender\}/, link_to(truncate_name(activity.sender.name),
                                                                      url_for(:controller=> activity.sender.subject.class.to_s.underscore.pluralize,
                                                                              :action=> :show, :id=> activity.sender.subject.slug, :only_path => false)))
      notification_text = notification_text.gsub(/\%\{confirm\}/,link_to(t('notification.confirm'),edit_contact_url(activity.receiver.contact_to!(activity.sender), :s => activity.receiver.slug)))
      notification_text = notification_text.gsub(/\%\{look\}/,link_to(t('notification.look'),
                                                                      url_for(:controller=> activity.sender.subject.class.to_s.underscore.pluralize,
                                                                              :action=> :show, :id=> activity.sender.subject.slug, :only_path => false)))
      notification_text = notification_text.gsub(/\%\{sender.name\}/,truncate_name(activity.sender.name))

      if activity.receiver.subject.is_a?(User)
        notification_text = notification_text.gsub(/\%\{whose\}/,t('notification.whose.user'))
        notification_text = notification_text.gsub(/\%\{who\}/,t('notification.who.user'))
      else
        notification_text = notification_text.gsub(/\%\{whose\}/,t('notification.whose.others', 
                                                    :receiver => truncate_name(activity.receiver.name)))
        notification_text = notification_text.gsub(/\%\{who\}/,truncate_name(activity.receiver.name))
      end
              
      if activity.direct_object.present?
        object = activity.direct_object
        object = object.subject if object.is_a? Actor
        notification_text=notification_text.gsub(/\%\{object\}/,link_to(object.class.to_s.underscore,
                                                                      url_for(:controller=> object.class.to_s.underscore.pluralize, :action=> :show, 
                                                                              :id=> object.id, :only_path => false)))
        notification_text=notification_text.gsub(/\%\{object.name\}/,object.class.to_s.underscore)
        
        
          
        if object.respond_to? :text
          notification_text=notification_text.gsub(/\%\{object.text\}/,link_to(object.text.truncate(100, :separator =>' '), 
                                                                          url_for(:controller=> object.class.to_s.underscore.pluralize, :action=> :show, 
                                                                                  :id=> object.id, :only_path => false))) 
        elsif SocialStream.objects.include? :document and object.is_a? Document
          notification_text=notification_text.gsub(/\%\{object.text\}/,link_to(object.file_file_name.truncate(100, :separator =>' '), 
                                                                          url_for(:controller=> object.class.to_s.underscore.pluralize, :action=> :show, 
                                                                                  :id=> object.id, :only_path => false)))
                  
        end
        #notification_text=notification_text.gsub(/\%\{object.image\}/,thumb_for(object)) if SocialStream.activity_forms.include? :document and object.is_a? Document
      
      else
        notification_text=notification_text.gsub(/\%\{object\}/,"nilclass")
        notification_text=notification_text.gsub(/\%\{object.name\}/,"nilclass")
      end

      notification_text
    end
    
    def decode_basic_notification notification_text, activity
      return if activity.nil?
      notification_text = notification_text.gsub(/\%\{sender\}/, truncate_name(activity.sender.name))
      notification_text = notification_text.gsub(/\%\{confirm\}/,t('notification.confirm'))
      notification_text = notification_text.gsub(/\%\{look\}/,t('notification.look'))
      notification_text = notification_text.gsub(/\%\{sender.name\}/,truncate_name(activity.sender.name))

      if activity.receiver.subject.is_a?(User)
        notification_text = notification_text.gsub(/\%\{whose\}/,t('notification.whose.user'))
        notification_text = notification_text.gsub(/\%\{who\}/,t('notification.who.user'))
      else
        notification_text = notification_text.gsub(/\%\{whose\}/,t('notification.whose.others', 
                                                  :receiver => truncate_name(activity.receiver.name)))
        notification_text = notification_text.gsub(/\%\{who\}/,truncate_name(activity.receiver.name))
      end

      if activity.direct_object.present?
        object = activity.direct_object
        object = object.subject if object.is_a? Actor
        notification_text=notification_text.gsub(/\%\{object\}/,object.class.to_s.underscore)
        notification_text=notification_text.gsub(/\%\{object.name\}/,object.class.to_s.underscore)
        notification_text=notification_text.gsub(/\%\{object.text\}/,object.text.truncate(100, :separator =>' ')) if object.respond_to? :text
      
        #notification_text=notification_text.gsub(/\%\{object.image\}/,thumb_for(object)) if SocialStream.activity_forms.include? :document and object.is_a? Document
      
      else
        notification_text=notification_text.gsub(/\%\{object\}/,"nilclass")
        notification_text=notification_text.gsub(/\%\{object.name\}/,"nilclass")
      end

      notification_text
    end
  end
end
