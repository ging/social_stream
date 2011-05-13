module AttachmentsHelper

  FORMATS = ["doc","ppt","xls","rar","zip","mp3","txt","pdf"]

  def format_image(format)
    if FORMATS.include?(format.split('/')[1])
      image_tag 'formats/'+format.split('/')[1]+'.png' 
    else
      image_tag 'formats/default.png'
    end
  end
  
end