module DocumentsHelper

  FORMATS = ["msword","vnd.ms-powerpoint","msexcel","rar","zip","mp3","plain","pdf"]
  
  def thumb_for(document)
    format = document.file_content_type 
    if FORMATS.include?(format.split('/')[1])
      image_tag 'formats/'+format.split('/')[1]+'.png' 
    else
      if is_image?(document)
        format = Mime::Type.lookup(document.file_content_type)
        image_tag url_for(document)+"."+format.to_sym.to_s+"?style=thumb"
      else
        image_tag 'formats/default.png'
      end
    end
  end
  
  def link_for_wall(document)
    format = Mime::Type.lookup(document.file_content_type)
    url_for(document)+"."+format.to_sym.to_s+"?style=thumb0"
  end
  
  def wrap_file_name(name)
    name
    if(name.length > 12)
      name[0,12]+"..."
    end
  end

  def is_image?(document)
    !(document.file_content_type =~ /^image.*/).nil?
  end
end