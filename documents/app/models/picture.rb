class Picture < Document
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style',
                    :styles => {:thumb48sq  => ["48x48"],
                                :thumbwall => ["130x97#"],
                                :preview => ["500>"]
                               }                              
                               
  define_index do
    indexes title
    indexes file_file_name, :as => :file_name
    indexes description
    indexes activity_object.tags.name, :as => :tags
    
    has created_at
  end    

  # Thumbnail file
  def thumb(size, helper)
    case size
      when 16
        "#{ size.to_s }/photo.png"
      when 48
        helper.picture_path self, :format => format, :style => 'thumb48sq'
      when 130
        helper.picture_path self, :format => format, :style => 'thumbwall'
      when 500
        helper.picture_path self, :format => format, :style => 'preview'
    end
  end
      
end
