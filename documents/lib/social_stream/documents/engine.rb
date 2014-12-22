module SocialStream
  module Documents
    class Engine < Rails::Engine
    
      initializer "social_stream-documents.register_mime_types" do

        # The ones that check if they are defined is because they are already defined in Rails 3.2 (or another gem)

        # Documents
        Mime::Type.register "text/plain", :txt
        Mime::Type.register "application/vnd.ms-word", :doc, [ "application/msword" ]
        Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx

        Mime::Type.register "application/vnd.ms-powerpoint", :ppt, [ "application/mspowerpoint" ]
        Mime::Type.register "application/vnd.openxmlformats-officedocument.presentationml.presentation", :pptx

        Mime::Type.register "application/vnd.ms-excel", :xls, [ "application/msexcel" ]
        unless defined? Mime::XLSX
          Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
        end

        Mime::Type.register "application/postscript", :ps, [ "application/ps" ]
        Mime::Type.register "application/vnd.oasis.opendocument.text", :odt
        Mime::Type.register "application/vnd.oasis.opendocument.presentation", :odp
        Mime::Type.register "application/vnd.oasis.opendocument.spreadsheet", :ods

        Mime::Type.register "application/rtf", :rtf
        Mime::Type.register "application/vnd.scribus", :sla

        # Zip and Rar
        unless defined? Mime::ZIP
          Mime::Type.register "application/zip", :zip
        end
        Mime::Type.register "application/x-rar", :rar

        #Fonts
        Mime::Type.register "font/truetype", :ttf
        Mime::Type.register "font/opentype", :otf
        Mime::Type.register "application/vnd.ms-fontobject", :eot
        Mime::Type.register "application/x-font-woff", :woff

        # PDF
        unless defined? Mime::PDF
          Mime::Type.register "application/pdf", :pdf
        end

        # Flash
        unless defined? Mime::SWF
          Mime::Type.register "application/x-shockwave-flash", :swf
        end

        # Pictures
        Mime::Type.register "image/x-xcf", :xcf
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
          Mime::Type.register "image/bmp",  :bmp, [ "image/x-ms-bmp" ]
        else
          # Manually register synonym
          Mime::BMP.instance_variable_get("@synonyms") << "image/x-ms-bmp"
          Mime::LOOKUP["image/x-ms-bmp"] = Mime::BMP
        end

        # Audio
        Mime::Type.register "audio/x-wav", :wav, [ "audio/wav" ]
        Mime::Type.register "audio/x-vorbis+ogg", :ogg, [ "application/ogg" ]
        Mime::Type.register "audio/webm", :webma
        Mime::Type.register "audio/3gpp", :gppa
        Mime::Type.register "audio/3gpp2", :gpa
        Mime::Type.register "audio/aac", :aac
        Mime::Type.register "audio/x-hx-aac-adts", :aac2
        Mime::Type.register "audio/mp4", :m4a
        # MPEG is currently reserved to 'video/mpeg'
        unless defined? Mime::MP3
          Mime::Type.register "audio/mpeg", :mp3
        end

        # Video
        Mime::Type.register "video/x-flv", :flv
        Mime::Type.register "video/webm", :webm
        Mime::Type.register "video/mp4", :mp4
        Mime::Type.register "video/quicktime", :mov
        Mime::Type.register "video/x-ms-asf", :wmv
        Mime::Type.register "video/x-m4v", :m4v
        Mime::Type.register "video/3gpp", :gpp #mimetype for .3gp videos
        Mime::Type.register "video/3gpp2", :gpp2 #mimetype for .3gp2 videos
        Mime::Type.register "video/ogg", :ogv
        Mime::Type.register "video/x-msvideo", :avi

      end

      initializer "social_stream-documents.model.register_activity_streams" do
        SocialStream::ActivityStreams.register :file,  :document
        SocialStream::ActivityStreams.register :image, :picture
        SocialStream::ActivityStreams.register :audio
        SocialStream::ActivityStreams.register :video
      end
    end
  end
end
