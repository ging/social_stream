module SocialStream
  module Documents
    class Engine < Rails::Engine
    
      initializer "social_stream-documents.register_mime_types" do
        # Documents
        Mime::Type.register "text/plain", :txt
        Mime::Type.register "application/x-rar", :rar
        Mime::Type.register "application/postscript", :ps, [ "application/ps" ]
        Mime::Type.register "application/vnd.oasis.opendocument.text", :odt
        Mime::Type.register "application/vnd.oasis.opendocument.presentation", :odp
        Mime::Type.register "application/vnd.oasis.opendocument.presentation", :ods
        Mime::Type.register "application/vnd.ms-word", :doc, [ "application/msword" ]
        Mime::Type.register "application/vnd.ms-powerpoint", :ppt, [ "application/mspowerpoint" ]
        Mime::Type.register "application/vnd.ms-excel", :xls, [ "application/msexcel" ]
        Mime::Type.register "application/rtf", :rtf
        Mime::Type.register "application/vnd.scribus", :sla
        # These are already defined in Rails 3.2
        unless defined? Mime::ZIP
          Mime::Type.register "application/zip", :zip
        end
        unless defined? Mime::PDF
          Mime::Type.register "application/pdf", :pdf
        end

        # Picture
        Mime::Type.register "image/x-xcf", :xcf
        # These are already defined in Rails 3.2
        unless defined? Mime::JPEG
          Mime::Type.register "image/jpeg", :jpeg, ["image/pjpeg","image/jpg"]
        end
        unless defined? Mime::GIF
          Mime::Type.register "image/gif",  :gif
        end
        unless defined? Mime::PNG
          Mime::Type.register "image/png",  :png,  [ "image/x-png" ]
        end
        unless defined? Mime::BMP
          Mime::Type.register "image/bmp",  :bmp
        end

        # Audio
        Mime::Type.register "audio/x-wav", :wav, [ "audio/wav" ]
        Mime::Type.register "audio/x-vorbis+ogg", :ogg, [ "application/ogg" ]
        Mime::Type.register "audio/webm", :webma
        # These are already defined in Rails 3.2
        unless defined? Mime::MPEG
          Mime::Type.register "audio/mpeg", :mpeg
        end

        # Video
        Mime::Type.register "video/x-flv", :flv
        Mime::Type.register "video/webm", :webm
      end

      initializer "social_stream-documents.views.toolbar" do
        SocialStream::Views::Toolbar.module_eval do
          include SocialStream::Views::Toolbar::Documents
        end
      end
    end
  end
end
