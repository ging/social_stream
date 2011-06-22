class Video < Document
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style.:extension',
                    :styles => {:webm => {:format => 'webm'}
                                #:vp8    => {:format => 'vp8'},
                                #:thumb   => {:geometry => "48x48#", :format => 'png', :time => 10}
                    },
                    :processors => [:ffmpeg]
end