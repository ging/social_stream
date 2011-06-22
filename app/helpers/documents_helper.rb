module DocumentsHelper

  FORMATS = ["doc","ppt","xls","rar","zip","mp3","plain","pdf"]
  
  def thumb_for(document)
    format = document.file_content_type
    if FORMATS.include?(format.split('/')[1])
      image_tag 'formats/'+format.split('/')[1]+'.png' 
    else
      if is_image?(document)
        image_tag document.file.url(:thumb)+"?style=thumb"
      else
        image_tag 'formats/default.png'
      end
    end
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