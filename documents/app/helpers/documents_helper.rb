module DocumentsHelper

  FORMATS = ["msword","vnd.ms-powerpoint","msexcel","rar","zip","mp3","plain","pdf"]
  
  
  #size can be any of the names that the document has size for
  def thumb_for(document, size)
    image_tag thumb_file_for(document, size)
  end

  def thumb_file_for(document, size)
    style = document.class.attachment_definitions[:file][:styles]

    format = style.respond_to?('[]') && style[:format] || document.format

    if style
      polymorphic_path document, format: format, thumb: size
    else
      FORMATS.include?(document.format) ?
        "todo" :
        "#{ size }/#{ document.class.to_s.underscore }.png"
    end
  end
  
  def image_tag_for (document)
    image_tag download_document_path document, 
              :id => dom_id(document) + "_img"
  end
  
  def link_for_wall(document)
    format = Mime::Type.lookup(document.file_content_type)

    polymorphic_path(document, :format => format, :style => 'thumbwall')
  end
  
  def show_view_for(document)
    render :partial => document.class.to_s.pluralize.downcase + '/' + document.class.to_s.downcase + "_show",
           :locals => {document.class.to_s.downcase.to_sym => document}
  end

  def document_details_tab_class(document, tab)
    editing = document && document.errors.present?

    case tab
    when :edit
      editing ? 'active' : ''
    when :info
      editing ? '' : 'active'
    else
      ''
    end
  end
end
