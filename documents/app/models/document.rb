class Document < ActiveRecord::Base
  include SocialStream::Models::Object

  IMAGE_FORMATS = ["doc","ppt","xls","rar","zip","mpeg","plain","pdf"]

  has_attached_file :file, 
                    :url => '/:class/:id.:extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style/:filename.:extension'
  
  validates_attachment_presence :file
  validates_presence_of :title
  
  before_validation(:on => :create) do
    set_title
  end
  
  define_index do
    indexes title
    indexes file_file_name, :as => :file_name
    indexes description
    indexes activity_object.tags.name, :as => :tags
    
    where "type IS NULL"
    
    has created_at
  end
  
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
  
  protected
  
  def set_title
    self.title = self.file_file_name
  end
    
end
