module DocumentsHelper

  FORMATS = ["msword","vnd.ms-powerpoint","msexcel","rar","zip","mp3","plain","pdf"]
  
  
  #size can be any of the names that the document has size for
  def thumb_for(document, size)
    image_tag document.thumb(size, self)
  end
  
  def thumb_file_for(document, size)
    document.thumb(size, self)
  end
  
  def image_tag_for (document)
    image_tag download_document_path document, 
              :id => dom_id(document) + "_img"
  end
  
  def link_for_wall(document)
    format = Mime::Type.lookup(document.file_content_type)

    polymorphic_path(document, :format => format, :style => 'thumb0')
  end
  
  def show_view_for(document)
    render :partial => document.class.to_s.pluralize.downcase + '/' + document.class.to_s.downcase + "_show",
           :locals => {document.class.to_s.downcase.to_sym => document}
  end
end
