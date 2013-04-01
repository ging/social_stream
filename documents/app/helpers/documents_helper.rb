module DocumentsHelper
  #size can be any of the names that the document has size for
  def thumb_for(document, size)
    image_tag thumb_file_for(document, size)
  end

  def thumb_file_for(document, size)
    style = document.class.attachment_definitions[:file][:styles]

    format = style.respond_to?('[]') && style[:format] || document.format

    if style
      polymorphic_path document, format: format, style: size
    else
      icon document, size
    end
  end

  # Return the right icon based on {#document}'s mime type
  def icon document, size = 50
    "<i class=\"icon_file_#{ size }-#{ icon_mime_type document }\"></i>".html_safe
  end

  # Find the right class for the icon of this document, based on its format
  def icon_mime_type document
    if SocialStream::Documents.icon_mime_types[:subtypes].include?(document.format)
      document.format
    elsif SocialStream::Documents.icon_mime_types[:types].include?(document.mime_type_type_sym)
      document.mime_type_type_sym
    else
      SocialStream::Documents.icon_mime_types[:default]
    end
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
