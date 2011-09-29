module ConferenceManager
  module Support
    module AgendaEntry
      
      CM_ATTRIBUTES = ["title", "cm_streaming", "cm_recording", "start_time", "end_time"]
      PAST_UNCHANGEABLE_ATTRIBUTES = ["cm_streaming", "cm_recording", "start_time", "end_time"]
      CURRENT_UNCHANGEABLE_ATTRIBUTES = ["cm_streaming", "cm_recording", "start_time"]
      WAKE_UP_TIME = 2.minutes
      SESSION_STATUS = {:init=>"Init",:recording=>"Recording",:recorded=>"Recorded",:published=>"Published"}
      
      
      class << self
        
        def included(base)
          base.class_eval do
            
            validate_on_create do |entry|
              
              # Validation: Session must be future
              if entry.errors.empty? && entry.event.uses_conference_manager? && entry.start_time < (Time.zone.now + WAKE_UP_TIME) 
                entry.errors.add_to_base(I18n.t('agenda.entry.error.past_times',
                                               :min_date => I18n.l(Time.zone.now + WAKE_UP_TIME), :format => '%d %b %Y %H:%M'))
              end
              
              #Session creation on Conference Manager 
              if entry.errors.empty? && entry.event.uses_conference_manager?
                
                cm_s =
                ConferenceManager::Session.new(:name => "none",
                                                :recording => entry.cm_recording?,
                                                :streaming => entry.cm_streaming?,
                                                :initDate=> ((entry.start_time - entry.event.start_date)*1000).to_i,
                                                :endDate=> ((entry.end_time - entry.event.start_date)*1000).to_i,
                                                :event_id => entry.event.cm_event_id) 
                begin
                  cm_s.save
                  entry.cm_session = cm_s
                rescue => e
                  entry.errors.add_to_base(e.to_s) 
                end        
              end
            end
            
            validate_on_update do |entry|
              
              if entry.errors.empty? && entry.event.uses_conference_manager?
                
                # Validation: In past sessions cannot be edited PAST_UNCHANGEABLE_ATTRIBUTES
                if entry.end_time_was.present? && entry.end_time_was.past? 
                  entry.errors.add_to_base(I18n.t('agenda.entry.error.attribute_unchangeable')) if (entry.changed & PAST_UNCHANGEABLE_ATTRIBUTES).any?
                  
                  # Validation: In current sessions cannot be edited CURRENT_UNCHANGEABLE_ATTRIBUTES
                elsif entry.end_time_was.present? && !(entry.end_time_was.past?) && entry.start_time_was.present? && Time.now.in_time_zone > (entry.start_time_was - WAKE_UP_TIME)
                  entry.errors.add_to_base(I18n.t('agenda.entry.error.attribute_unchangeable')) if (entry.changed & CURRENT_UNCHANGEABLE_ATTRIBUTES).any?
                end
              end
            
              #Session update on Conference Manager
              if !entry.past? && entry.errors.empty? && entry.event.uses_conference_manager? && (((entry.changed & CM_ATTRIBUTES).any?)||(entry.date_update_action.eql?"move_event")||(entry.date_update_action.eql?"start_date")) 
                if (!entry.date_update_action.eql?"move_event")                   
                  cm_s = entry.cm_session
                  new_params = { :name => entry.title,
                               :recording => entry.cm_recording?,
                               :streaming => entry.cm_streaming?,
                               :initDate=> ((entry.start_time - entry.event.start_date)*1000).to_i,
                               :endDate=> ((entry.end_time - entry.event.start_date)*1000).to_i,
                               :event_id => entry.event.cm_event_id }
                  
                  if entry.cm_session?
                    cm_s.load(new_params) 
                  else
                    entry.errors.add_to_base(I18n.t('event.error.cm_connection'))
                  end
                  
                  begin        
                    cm_s.save
                  rescue => e
                    if cm_s.present?  
                      entry.errors.add_to_base(e.to_s) 
                    end  
                  end     
                end
              end
            end
            
            before_destroy do |entry|
              #Delete session in Conference Manager if event is not in-person
              if entry.event.uses_conference_manager?
                begin
                  cm_s = entry.cm_session     
                  cm_s.destroy    
                rescue => e  
                  entry.errors.add_to_base(I18n.t('agenda.entry.error.delete'))
                  false
                end     
              end 
            end
          end
        end
      end
      
      def cm_session
        begin
          @cm_session ||=
          ConferenceManager::Session.find(cm_session_id,
                                            :params => { :event_id => event.cm_event_id })
        rescue
          nil
        end  
      end
      
      def cm_session=(cms_s)
        self.cm_session_id = cms_s.id
        @cm_session = cms_s
      end
      
      def cm_session?
        cm_session.present?
      end
      
      
      def status
        begin
          @session_status ||=
          ConferenceManager::SessionStatus.find(:status,
                                            :params => { :event_id => event.cm_event_id,
                                                         :session_id => cm_session_id})
        rescue
          nil
        end 
      end
      
      
      def can_edit_hours?
        !(event.uses_conference_manager? && past?) 
      end
      
      #Return  a String that contains a html with the video player for this session
      #with the default width and height, 640x480
      def player
        player("640","480")
      end
      
      #Return  a String that contains a html with the video player for this session
      def player(width, height)
        begin
          @cm_player_session ||=
          ConferenceManager::PlayerSession.find(:player,
              :params => { :event_id => event.cm_event_id,
                           :session_id => cm_session.id, 
                           :width => width,
                           :height => height})
          @cm_player_session.html
        rescue
          nil
        end
      end
      
      #Return  a String that contains a html with the video editor for this session
      def editor(width, height)
        begin
          @cm_player_session ||=
          ConferenceManager::EditorSession.find(:player,
              :params => { :event_id => event.cm_event_id,
                           :session_id => cm_session.id, 
                           :width => width,
                           :height => height})
          @cm_player_session.html
        rescue
          nil
        end
      end
      
      #method that changes the recording status of this session
      #remember that the rest of the sessions of this event will stop the recording if you init one
      def change_status(new_status)       
        cm_status = status
        new_params = {:event_id => event.cm_event_id,
                      :session_id => cm_session_id,  
                      :status => new_status}
        cm_status.load(new_params)
        begin       
          cm_status.save
        rescue => e
          if cm_status.present?  
            errors.add_to_base(e.to_s) 
          end  
        end  
      end
      
      #method to check if the video has been published
      #either by the user or because the event has finished
      def check_published_recording
        cm_status = status
        debugger
        puts "hola"
      end


      #method to get the session status
      #it can be any in SESSION_STATUS
      def session_status
        cm_status = status
        if cm_status
          cm_status.attributes["status"]
        end
      end
      
      #method to start the recording
      #remember that the rest of the sessions of this event will stop the recording
      def start_recording
        cm_status = status
        new_params = {:event_id => event.cm_event_id,
                      :session_id => cm_session_id,  
                      :status => SESSION_STATUS[:recording]}
        cm_status.load(new_params)
        begin       
          cm_status.save
        rescue => e
          if cm_status.present?  
            errors.add_to_base(e.to_s) 
          end  
        end  
      end
      
      
      #method to stop the recording
      def stop_recording
        cm_status = status
        new_params = {:event_id => event.cm_event_id,
                      :session_id => cm_session_id,  
                      :status => SESSION_STATUS[:recorded]}
        cm_status.load(new_params)
        begin       
          cm_status.save
        rescue => e
          if cm_status.present?  
            errors.add_to_base(e.to_s) 
          end  
        end  
      end
      
      
      
      
    end
  end
end
