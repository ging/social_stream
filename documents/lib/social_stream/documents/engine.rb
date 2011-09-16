module SocialStream
  module Documents
    class Engine < Rails::Engine
    
      initializer "social_stream-documents.register_mime_types" do
        # Documents
        Mime::Type.register "text/plain", :txt
        Mime::Type.register "application/zip", :zip
        Mime::Type.register "application/x-rar", :rar
        Mime::Type.register "application/pdf", :pdf
        Mime::Type.register "application/postscript", :ps, [ "application/ps" ]
        Mime::Type.register "application/vnd.oasis.opendocument.text", :odt
        Mime::Type.register "application/vnd.oasis.opendocument.presentation", :odp
        Mime::Type.register "application/vnd.oasis.opendocument.presentation", :ods
        Mime::Type.register "application/vnd.ms-word", :doc, [ "application/msword" ]
        Mime::Type.register "application/vnd.ms-powerpoint", :ppt, [ "application/mspowerpoint" ]
        Mime::Type.register "application/vnd.ms-excel", :xls, [ "application/msexcel" ]
        Mime::Type.register "application/rtf", :rtf
        Mime::Type.register "application/vnd.scribus", :sla

        # Picture
        Mime::Type.register "image/jpeg", :jpeg, ["image/pjpeg","image/jpg"]
        Mime::Type.register "image/gif",  :gif
        Mime::Type.register "image/png",  :png,  [ "image/x-png" ]
        Mime::Type.register "image/bmp",  :bmp
        Mime::Type.register "image/x-xcf", :xcf

        # Audio
        Mime::Type.register "audio/x-wav", :wav, [ "audio/wav" ]
        Mime::Type.register "audio/mpeg", :mpeg
        Mime::Type.register "audio/x-vorbis+ogg", :ogg, [ "application/ogg" ]

        # Video
        Mime::Type.register "video/x-flv", :flv
      end

    end
  end
end
