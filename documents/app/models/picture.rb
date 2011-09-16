class Picture < Document
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style.:extension',
                    :styles => {:thumb  => ["48x48#"],
                                :thumb0 => ["130x80#"]
                               }                                  
  # Thumbnail file
  def thumb(size, helper)
    case size
      when 16
        "#{ size.to_s }/photo.png"
      when 48
        helper.picture_path self, :format => format, :style => 'thumb'   
      when 130
        helper.picture_path self, :format => format, :style => 'thumb0'    
    end
  end
    
  
end
