SocialStream::Documents.setup do |config| 
  # Configure picture thumbnails
  #
  # config.picture_styles = {
  #   :"170x127#" => ["170x127#"],
  #   # this one preserves A4 proportion: 210x297
  #   :"80x113#" => ["80x113#"],
  #   :"500" => ["500>"]
  #  }

  # Configure audio thumbnails
  #
  # config.audio_styles = {
  #    webma: {
  #      format: 'webm',
  #      processors: [ :ffmpeg ]
  #    },
  #    # You need to add the `paperclip_waveform` gem to your Gemfile
  #    # to get pngs with the audio wave form
  #    waveform: {
  #      format: :png,
  #      convert_options: {
  #        color: :transparent,
  #        background_color: '#333333',
  #        width: 460,
  #        height: 75
  #      },
  #      processors: [ :waveform ]
  #    }
  # }

  # Configure video thumbnails
  #
  #  @@video_styles = {
  #    :webm => { :format => 'webm' },
  #    :flv  => { :format => 'flv' },
  #    :mp4  => { :format => 'mp4' },
  #    :"170x127#" => { :geometry => "170x127#", :format => 'png', :time => 5 }
  #  }

  # List of mime types that have an icon defined
  # config.icon_mime_types  = {
  #    default: :default,
  #    types: [
  #      :text, :image, :audio, :video
  #    ],
  #    subtypes: [
  #      :txt, :ps, :pdf, :sla, 
  #      :odt, :odp, :ods, :doc, :ppt, :xls, :rtf,
  #      :rar, :zip,
  #      :jpeg, :gif, :png, :bmp, :xcf,
  #      :wav, :ogg, :webma, :mpeg,
  #      :flv, :webm, :mp4
  #    ]
  #  }
end
