class Picture < Document
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style.:extension',
                    :styles => {:thumb  => ["48x48#"],
                                :thumb0 => ["130x80#"]
                               }                                  
end