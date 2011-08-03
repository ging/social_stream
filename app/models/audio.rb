class Audio < Document
  after_save :audioprocess
  
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style.:extension',
                    :styles => {:webma => {:format => 'webm'}                                
                    },:processors => [:ffmpeg]
  
  def audioprocess
    Resque.enqueue(Audioencoder, self.id)
  end
     
              
  # Thumbnail file
  def thumb(size, helper)
      "#{ size.to_s }/audio.png"
  end
  
end
