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
                      
  # Thumbnail file
  def thumb(size, helper)
      "#{ size.to_s }/video.png"
  end
  
end
