module SocialStreamFiles
  class Engine < Rails:Engine
    
    initializer "socialstream-files.file_in_social_stream_objects" do
      SocialStream.objects << :file unless SocialStream.objects.include?(:file)
    end
  
  end
end