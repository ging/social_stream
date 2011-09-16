class Document < ActiveRecord::Base
  include SocialStream::Models::Object

  IMAGE_FORMATS = ["doc","ppt","xls","rar","zip","mpeg","plain","pdf"]

  STYLE_FORMAT = {"webm" =>"webm", "flv"=>"flv", "thumb"=>"png", "thumb0"=>"png", "webma"=>"webm"}

  STYLE_MIMETYPE = {"webm" =>"video/webm", "flv"=>"video/x-flv", "thumb"=>"image/png", "thumb0"=>"image/png", "mp3"=>"audio/mpeg", "webma"=>"audio/webm"}

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

  def mime_type
    Mime::Type.lookup(file_content_type)
  end

  def format
    mime_type.to_sym
  end

  # Thumbnail file
  def thumb(size, helper)
    if format && IMAGE_FORMATS.include?(format.to_s)
      "#{ size.to_s }/#{ format }.png"
    else
      "#{ size.to_s }/default.png"
    end
  end
    
end
