class Document < ActiveRecord::Base
  
  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style.:extension',
                    :styles => {:thumb => ["32x32#", :png]}
  
  validates_attachment_presence :file
  
end
