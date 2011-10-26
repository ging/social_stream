module DocumentsHelper

  FORMATS = ["msword","vnd.ms-powerpoint","msexcel","rar","zip","mp3","plain","pdf"]
  
  
  #size can be any of the names that the document has size for
  def thumb_for(document, size)
    image_tag document.thumb(size, self)
  end
  
  def thumb_file_for(document, size)
    document.thumb(size, self)
  end
    
  def link_for_wall(document)
    format = Mime::Type.lookup(document.file_content_type)

    polymorphic_path(document, :format => format, :style => 'thumb0')
  end
end
