class Picture < Document
  has_attached_file :file, 
                    :url => '/:class/:id.:content_type_extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style',
                    :styles => SocialStream::Documents.picture_styles
                               
  define_index do
    activity_object_index

    indexes file_file_name, :as => :file_name
  end    
end
