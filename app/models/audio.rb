class Audio < Document
 
  # Thumbnail file
  def thumb(size, helper)
    if format && IMAGE_FORMATS.include?(format.to_s)
      "#{ size.to_s }/audio.png"
    else
      "#{ size.to_s }/audio.png"
    end
  end
end
