class Video < Document  
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style.:extension',
                    :styles => {:webm => {:format => 'webm'},
                                :flv => { :format => 'flv' },
                                :thumb   => {:geometry => "48x48" , :format => 'png', :time => 5},
                                :thumb0  => {:geometry => "130x80", :format => 'png', :time => 5}
                    },:processors => [:ffmpeg]
                    
  process_in_background :file
  
  define_index do
    indexes title
    indexes file_file_name, :as => :file_name
    indexes description
    indexes activity_object.tags.name, :as => :tags
    
    has created_at
  end
                      
  # Thumbnail file
  def thumb(size, helper)
      "#{ size.to_s }/video.png"
  end
  
end
