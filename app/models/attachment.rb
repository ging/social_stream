class Attachment < ActiveRecord::Base
  
  has_attached_file :file, 
                    :url => '/:class/:id.:extension', #'/:class/:id/:style.:extension',
                    :path => ':rails_root/attachments/:class/:id_partition/:style.:extension'
  
  validates_attachment_presence :file
  
end
