class Audio < Document  
  has_attached_file :file, 
                    :url => '/:class/:id.:content_type_extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style',
                    :styles => SocialStream::Documents.audio_styles,
                    :processors => [ :ffmpeg, :waveform ]
  
  process_in_background :file    
  
  define_index do
    activity_object_index

    indexes file_file_name, :as => :file_name
  end 
              
end
