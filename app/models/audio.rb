class Audio < Document
 
  # Thumbnail file
  def thumb(size, helper)
      "#{ size.to_s }/audio.png"
  end
end
