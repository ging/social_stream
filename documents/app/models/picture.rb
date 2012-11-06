class Picture < Document
  has_attached_file :file, 
                    :url => '/:class/:id.:content_type_extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style',
                    :styles => SocialStream::Documents.picture_styles
                               
  define_index do
    activity_object_index

    indexes file_file_name, :as => :file_name
  end    

  # Thumbnail file
  def thumb(size, helper)
    case size
      when 16
        "#{ size.to_s }/photo.png"
      when 48
        helper.picture_path self, :format => format, :style => 'thumb48sq'
      when 80
        helper.picture_path self, :format => format, :style => 'midwall'
      when 130
        helper.picture_path self, :format => format, :style => 'thumbwall'
      when 500
        helper.picture_path self, :format => format, :style => 'preview'
      when 1000
        helper.picture_path self, :format => format, :style => 'original'
    end
  end
      
end
