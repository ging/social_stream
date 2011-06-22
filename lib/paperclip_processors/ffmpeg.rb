#from https://github.com/owahab/paperclip-ffmpeg.git
module Paperclip
  class Ffmpeg < Processor
    attr_accessor :geometry, :format, :whiny, :convert_options

    # Creates a Video object set to work on the +file+ given. It
    # will attempt to transcode the video into one defined by +target_geometry+
    # which is a "WxH"-style string. +format+ should be specified.
    # Video transcoding will raise no errors unless
    # +whiny+ is true (which it is, by default. If +convert_options+ is
    # set, the options will be appended to the convert command upon video transcoding
    def initialize file, options = {}, attachment = nil
      @convert_options = {
        :ab            => '64k',
        :ac            => 2,
        :ar            => 44100,
        :b             => '1200k',
        :deinterlace   => nil,
        :r             => 25,
        :y             => nil 
      }
      @convert_options.reverse_merge! options[:convert_options] unless options[:convert_options].nil? || options[:convert_options].class != Hash
      
      @geometry        = options[:geometry]
      @file            = file
      @keep_aspect     = !@geometry.nil? && @geometry[-1,1] != '!'
      @enlarge_only    = @keep_aspect    && @geometry[-1,1] == '<'
      @shrink_only     = @keep_aspect    && @geometry[-1,1] == '>'
      @whiny           = options[:whiny].nil? ? true : options[:whiny]
      @format          = options[:format]
      @time            = options[:time].nil? ? 3 : options[:time]
      @current_format  = File.extname(@file.path)
      @basename        = File.basename(@file.path, @current_format)
      @meta            = identify
      attachment.instance_write(:meta, @meta)
    end
    # Performs the transcoding of the +file+ into a thumbnail/video. Returns the Tempfile
    # that contains the new image/video.
    def make
      src = @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode
      
      begin
        parameters = []
        # Add geometry
        if @geometry
          # Extract target dimensions
          if @geometry =~ /(\d*)x(\d*)/
            target_width = $1
            target_height = $2
          end
          # Only calculate target dimensions if we have current dimensions
          unless @meta[:size].nil?
            current_geometry = @meta[:size].split('x')
            # Current width and height
            current_width = current_geometry[0]
            current_height = current_geometry[1]
            if @keep_aspect
              if current_width.to_i >= target_width.to_i && !@enlarge_only
                # Keep aspect ratio
                width = target_width.to_i
                height = (width.to_f / (@meta[:aspect].to_f)).to_i
              elsif current_width.to_i < target_width.to_i && !@shrink_only
                # Keep aspect ratio
                width = target_width.to_i
                height = (width.to_f / (@meta[:aspect].to_f)).to_i
                # We should add the delta as a padding area
                pad_h = (target_height.to_i - current_height.to_i) / 2
                pad_w = (target_width.to_i - current_width.to_i) / 2
                @convert_options[:vf] = "pad=#{width.to_i}:#{height.to_i}:#{pad_h}:#{pad_w}:black"
              end
            else
              # Do not keep aspect ratio
              width = target_width
              height = target_height
            end
          end
          unless width.nil? || height.nil? || @convert_options[:vf]
            @convert_options[:s] = "#{width.to_i}x#{height.to_i}"
          end
        end
        # Add format
        case @format
        when 'jpg', 'jpeg', 'png', 'gif' # Images
          @convert_options[:f] = 'image2'
          @convert_options[:ss] = @time
          @convert_options[:vframes] = 1
        end
        
        parameters << '-i :source'
        parameters << @convert_options.map { |k,v| "-#{k.to_s} #{v} "}
        parameters << ":dest"

        parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")
        success = Paperclip.run("ffmpeg", parameters, :source => "#{File.expand_path(src.path)}", :dest => File.expand_path(dst.path))
        
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "error while processing video for #{@basename}." if @whiny
      end

      dst
    end
    
    def identify
      meta = {}
      command = "ffmpeg -i #{File.expand_path(@file.path)} 2>&1"
      Paperclip.log(command)
      ffmpeg = IO.popen(command)
      ffmpeg.each("\r") do |line|
        if line =~ /((\d*)\s.?)fps,/
          meta[:fps] = $1.to_i
        end
        # Matching lines like:
        # Video: h264, yuvj420p, 640x480 [PAR 72:72 DAR 4:3], 10301 kb/s, 30 fps, 30 tbr, 600 tbn, 600 tbc
        if line =~ /Video:(.*)/
          v = $1.to_s.split(',')
          size = v[2].strip!.split(' ').first
          meta[:size] = size.to_s
          meta[:aspect] = size.split('x').first.to_f / size.split('x').last.to_f
        end
        # Matching Duration: 00:01:31.66, start: 0.000000, bitrate: 10404 kb/s
        if line =~ /Duration:(\s.?(\d*):(\d*):(\d*\.\d*))/
          meta[:length] = $2.to_s + ":" + $3.to_s + ":" + $4.to_s
          meta[:frames] = ($4.to_i + ($3.to_i * 60) + ($2.to_i * 60 * 60)) * meta[:fps]
        end
      end
      meta
    end
  end
  
  class Attachment
    def meta
      instance_read(:meta)
    end
  end
end