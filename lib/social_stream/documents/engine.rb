module SocialStream
  module Documents
    class Engine < Rails::Engine
    
      initializer "social_stream-documents.documents_in_social_stream_objects" do
        SocialStream.objects.push(:document) unless SocialStream.objects.include?(:document)
      end
      
      initializer "social_stream-documents.register_mime_types" do
        Mime::Type.register "image/jpeg", :jpeg, [ "image/pjpeg" ]
        Mime::Type.register "image/gif", :gif
        Mime::Type.register "image/png", :png, [ "image/x-png" ]
        Mime::Type.register "image/bmp", :bmp
      end

    end
  end
end
