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
             

  # JSON, special edition for video files
  def as_json(options = nil)
    {
      :id => id,
      :type => "audio",
      :title => title,
      :description => description,
      :author => author.name,
      :original_source => options[:helper].polymorphic_url(self, format: self.format),
      :sources => [
        { type: Mime::MP3.to_s, src: options[:helper].polymorphic_url(self, format: :mp3) },
        { type: Mime::WAV.to_s,  src: options[:helper].polymorphic_url(self, format: :wav) },
        { type: Mime::WEBMA.to_s,  src: options[:helper].polymorphic_url(self, format: :webma) }
      ]
    }
  end 
end
