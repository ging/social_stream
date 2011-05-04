class Attachment < ActiveRecord::Base
  has_attached_file :file, 
                    :url => '/:class/:id/:style.:extension',
                    :path => ':rails_root/attachments/:class/:id_partition/:style.:extension'
  
  def can_be_downloaded?
    true #TO-DO
  end
end
