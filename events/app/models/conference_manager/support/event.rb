module ConferenceManager
  module Support
    # This module provides support for Events organized by the ConferenceManger
    module Event
      
      CM_ATTRIBUTES = ["name", "cm_mode", "start_date", "end_date", "web_bw", "isabel_bw", "sip_interface", "httplivestreaming_bw", "permalink"]
      #in these arrays the number in kb is lower than in the comments because we pass the conference manager interface
      #only the video bandwidth, and the total is about 50kb lower
      WEB_BANDWIDTH = [100000, 200000, 400000] #equivalents: low (150K), medium (250K), high (450K)
      WEB_CODEC = ["H264","H264","H263"] #equivalents: low (h.264), medium (h.264), high (sorenson)
      RECORDING_BANDWIDTH = [0, 200000, 500000] #equivalents low (0) we don't use it, medium (250K), high (550K)
      RECORDING_CODEC = ["H264","H264","H264"] #equivalents: low (H.264), medium (h.264), high (h.264)  
      
      WEB_BW_HASH_FOR_DROP_DOWN = {"100000"=> ["Low (150K H.264)", "0"], "200000" => ["Medium (250K H.264)", "1"], "400000"=>["High (450K Sorenson)", "2"]}
      RECORDING_HASH_FOR_DROP_DOWN = {"0"=>["Medium (250K H.264)", "1"],"200000"=>["Medium (250K H.264)", "1"],"500000"=>["High (550K H.264)", "2"]}
      
      class << self
        def included(base)
          base.class_eval do

            validate_on_create do |event|
              if event.uses_conference_manager?
                if event.recording_type == ::Event::RECORDING_TYPE.index(:manual)
                  end_date_after_adjust = event.end_date + ::Event::EXTRA_TIME_FOR_EVENTS_WITH_MANUAL_REC
                else
                  end_date_after_adjust = event.end_date
                end
                cm_e =
                  ConferenceManager::Event.new(:name => event.name,
                                               :mode => event.cm_mode,
                                               :initDate => event.start_date,
                                               :endDate => end_date_after_adjust,
                                               :enable_web => "1",
                                               :enable_isabel => "1",
                                               :enable_sip => event.sip_interface?,
                                               :enable_httplivestreaming => "0",
                                               :isabel_bw => event.isabel_bw,
                                               :web_bw => WEB_BANDWIDTH[event.web_bw],
                                               :recording_bw => RECORDING_BANDWIDTH[event.recording_bw],
                                               :httplivestreaming_bw => WEB_BANDWIDTH[event.web_bw],
                                               :web_codec => WEB_CODEC[event.web_bw],
                                               :recording_codec => RECORDING_CODEC[event.recording_bw],
                                               :path => "attachments/conferences/#{event.permalink}")
                begin 
                  cm_e.save
                  event.cm_event_id = cm_e.id
                rescue StandardError => e
                  event.errors.add_to_base(e.to_s)
                end        
              end
            end
           
            validate_on_update do |event|           
              if !event.past? && event.uses_conference_manager? && (event.changed & CM_ATTRIBUTES).any? 
                if event.recording_type == ::Event::RECORDING_TYPE.index(:manual)
                  end_date_after_adjust = event.end_date + ::Event::EXTRA_TIME_FOR_EVENTS_WITH_MANUAL_REC
                else
                  end_date_after_adjust = event.end_date
                end
                new_params = { :name => event.name,
                               :mode => event.cm_mode,
                               :initDate => event.start_date,
                               :endDate => end_date_after_adjust,
                               :enable_web => "1",
                               :enable_isabel => "1",
                               :enable_sip => event.sip_interface?,
                               :enable_httplivestreaming => "0",
                               :isabel_bw => event.isabel_bw,
                               :web_bw => WEB_BANDWIDTH[event.web_bw],
                               :recording_bw => RECORDING_BANDWIDTH[event.recording_bw],
                               :httplivestreaming_bw => WEB_BANDWIDTH[event.web_bw],
                               :web_codec => WEB_CODEC[event.web_bw],
                               :recording_codec => RECORDING_CODEC[event.recording_bw],
                               :path => "attachments/conferences/#{event.permalink}" }
                cm_event = event.cm_event
                cm_event.load(new_params)  

                begin
                  cm_event.save
                rescue  StandardError =>e
                  event.errors.add_to_base(e.to_s)  
                end
              end  
            end

            before_destroy do |event|
              if event.uses_conference_manager?
              # Delete event in conference Manager
                begin
                  cm_event = ConferenceManager::Event.find(event.cm_event_id)
                  cm_event.destroy  
                rescue ActiveResource::ResourceNotFound => e
                  true  
                else        
                  true
                end
              end
            end
          end
        end
      end
     
      # The conference manager mode
      def cm_mode
        case vc_mode_sym
        when :telemeeting
          'meeting'
        when :teleconference
          'conference'
        when :teleclass
          'class'
        else
          raise "Unknown Conference Manager mode: #{ vc_mode_sym }"
        end
      end

      def uses_conference_manager?
        case vc_mode_sym
        when :telemeeting, :teleconference, :teleclass
          true
        else
          false
        end
      end
     
      def cm_event
        unless self.cm_event_id
          return nil
        end
        begin
          @cm_event ||= ConferenceManager::Event.find(self.cm_event_id)
        rescue
          nil
        end  
      end
           
      
      def cm_event?
        cm_event.present?
      end

      def web_url
        cm_event.try(:web_url)
      end
      
      def sip_url
        cm_event.try(:sip_url)
      end
      
      def isabel_url
        cm_event.try(:isabel_url) 
      end
      
      def httplivestreaming_url
        cm_event.try(:httplivestreaming_url) 
      end

      # Returns a String that contains a html with the video of the Isabel Web Gateway
      %w( player editor streaming ).each do |obj|
        eval <<-EOM
      def #{ obj }(width = '640', height = '480', type = 'flash')
        begin      
          cm_#{ obj } ||=
            ConferenceManager::#{ obj.classify }.find(:#{ obj },
                                                      :params => { :width => width,
                                                                   :height => height,
                                                                   :type => type,
                                                                   :event_id => cm_event_id })
          cm_#{ obj }.html 
        rescue
          nil
        end
      end
        EOM
      end

      def web(username, width = '640', height = '480')
        begin      
          cm_web ||=
            ConferenceManager::Web.find(:web,
                                        :params => { :username => username,
                                                     :width => width,
                                                     :height => height,
                                                     :event_id => cm_event_id })
          cm_web.html 
        rescue
          nil
        end
      end
   
      
      def webstats
        begin  
          cm_webstats ||=
            ConferenceManager::Webstats.find(:webstat,
                                        :params => { :event_id => cm_event_id })
          cm_webstats.html 
        rescue
          nil
        end
      end
      
      def webmap
        begin      
          cm_webmap ||=
            ConferenceManager::Webmap.find(:webmap,
                                        :params => { :event_id => cm_event_id })
          cm_webmap.html 
        rescue
          nil
        end
      end
      
      
      def start!
        begin
          ConferenceManager::Start.create(:event_id => cm_event_id)
        rescue  StandardError => e
          errors.add_to_base(e.to_s)  
        end
      end
    
    
      #method to ask the conference manager the id of the entry being recorded
      #returns nil if nothing is being recorded
      def get_entry_being_recorded
        begin
          @event_status ||= ConferenceManager::EventStatus.find("event-status", :params => { :event_id => cm_event_id})
          unless @event_status.nil?
            if @event_status.attributes["recording_session"]              
              ae = ::AgendaEntry.find_by_cm_session_id(@event_status.attributes["recording_session"])              
              if ae.event == self
                return ae.id
              end
            end            
          end
          return nil
        rescue
          nil
        end        
      end

    end
  end
end
