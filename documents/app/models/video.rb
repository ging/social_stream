class Video < Document  
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style',
                    :styles => {
                      :webm => {:format => 'webm'},
                      :flv  => {:format => 'flv'},
                      :mp4  => {:format => 'mp4'},
                      :poster  => {:format => 'png', :time => 5},
                      :thumb48sq  => {:geometry => "48x48" , :format => 'png', :time => 5},
                      :thumbwall => {:geometry => "130x97#", :format => 'png', :time => 5}
                    },
                    :processors => [:ffmpeg]
                    
  process_in_background :file
  
  define_index do
    indexes activity_object.title
    indexes file_file_name, :as => :file_name
    indexes activity_object.description
    indexes activity_object.tags.name, :as => :tags
    
    has created_at
  end
                      
  # Thumbnail file
  def thumb(size, helper)
      "#{ size.to_s }/video.png"
  end

 # JSON, special edition for video files
  def to_json me=self
    {:id => activity_object_id,
     :title => title,
     :description => description,
     :author => author.name,
     :poster => file(:poster).to_s,
     :sources => [ { :type => Mime::WEBM.to_s,  :src => file(:webm).to_s },
                   { :type => Mime::MP4.to_s,   :src => file(:mp4).to_s },
                   { :type => Mime::FLV.to_s, :src => file(:flv).to_s }
                 ]
    }.to_json
  end
  
end
