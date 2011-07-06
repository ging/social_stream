module SocialStream
  module Documents
    class Engine < Rails::Engine
    
      initializer "social_stream-documents.register_mime_types" do
        Mime::Type.register "image/jpeg", :jpeg, ["image/pjpeg","image/jpg"]
        Mime::Type.register "image/gif", :gif
        Mime::Type.register "image/png", :png, [ "image/x-png" ]
        Mime::Type.register "image/bmp", :bmp
      end

    end
  end
end
