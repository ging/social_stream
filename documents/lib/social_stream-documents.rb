require 'social_stream/documents/dependencies'

module SocialStream
  module Views
    module Toolbar
      autoload :Documents, 'social_stream/views/toolbar/documents'
    end
  end

  module Documents
    # Picture thumbnails
    mattr_accessor :picture_styles
    @@picture_styles = {
      :thumb48sq  => ["48x48"],
      :"170x127#" => ["170x127#"],
      # midwall preserves A4 proportion: 210x297
      :midwall => ["80x113#"],
      :"500" => ["500>"]

    }

    mattr_accessor :audio_styles
    @@audio_styles = { :webma => {:format => 'webm'} }

    mattr_accessor :video_styles
    @@video_styles = {
      :webm => { :format => 'webm' },
      :flv  => { :format => 'flv' },
      :mp4  => { :format => 'mp4' },
      :poster  => { :format => 'png', :time => 5 },
      :thumb48sq  => { :geometry => "48x48" , :format => 'png', :time => 5 },
      :"170x127#" => { :geometry => "170x127#", :format => 'png', :time => 5 }
    }

    # List of mime types that have an icon defined
    mattr_accessor :icon_mime_types
    @@icon_mime_types = {
      default: :default,
      types: [
        :text, :image, :audio, :video
      ],
      subtypes: [
        :txt, :ps, :pdf, :sla, 
        :odt, :odp, :ods, :doc, :ppt, :xls, :rtf,
        :rar, :zip,
        :jpeg, :gif, :png, :bmp, :xcf,
        :wav, :ogg, :webma, :mp3,
        :flv, :webm, :mp4
      ]
    }

    class << self
      def setup
        yield self
      end
    end

    # Add :document to SocialStream.objects and SocialStream.activity_forms by default
    # It can be configured by users at application's config/initializers/social_stream.rb
    [ :picture, :video, :audio, :document].each do |o|
    SocialStream.quick_search_models.push(o) unless SocialStream.quick_search_models.include?(o)
    SocialStream.extended_search_models.push(o) unless SocialStream.extended_search_models.include?(o)
    end
    
    %w(objects activity_forms).each do |m|
      SocialStream.__send__(m).push(:document) unless SocialStream.__send__(m).include?(:document)
    end
  end
end

require 'social_stream/documents/engine'
