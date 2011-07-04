class Document < ActiveRecord::Base
  include SocialStream::Models::Object

  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style.:extension'
  
  validates_attachment_presence :file
  
  class << self 
    def new(*args)
      if !(self.name == "Document")
        return super
       end 
      doc = super
      
      if(doc.file_content_type.nil?)
        return doc
      end
      
      if !(doc.file_content_type =~ /^image.*/).nil?
        return Picture.new *args
      end
      
      if !(doc.file_content_type =~ /^audio.*/).nil?
        return Audio.new *args
      end
      
      if !(doc.file_content_type =~ /^video.*/).nil?
        return Video.new *args
      end
      
      return doc
    end
  end
  
end
