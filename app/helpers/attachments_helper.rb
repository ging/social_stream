module AttachmentsHelper

  FORMATS = ["doc","ppt","xls","rar","zip","mp3","txt","pdf"]

  def format_image(format)
    if FORMATS.include?(format.split('/')[1])
      image_tag 'formats/'+format.split('/')[1]+'.png' 
    else
      image_tag 'formats/default.png'
    end
  end
  
  def wrap_file_name(name)
    name
    if(name.length > 12)
      name[0,12]+"..."
    end
  end
  
end