namespace :i18n do
  task "common" do
    require 'yaml'
    begin
      require 'social_stream/components'
    rescue LoadError
      # Use this task from social_stream global gem
      # (which defines social_stream/components),
      # as well as from any application using social_stream-base
    end

    @engines = [ '.' ]

    if defined? SocialStream::ALL_COMPONENTS
      @engines += SocialStream::ALL_COMPONENTS
    end
  end

  desc "Synchronize i18n files"
  task "sync" => "common" do
    Hash.class_eval do
      def sync(h)
        en_hash = h.dup

        each_key do |self_key|
          en_val = en_hash.delete(self_key)

          case en_val
          when NilClass
            delete(self_key)
          when Hash
            if self[self_key].is_a?(Hash)
              self[self_key].sync(en_val)
            else
              self[self_key] = en_val
            end
          when String
            if self[self_key].nil?
              self[self_key] = en_val
            end
          else
            raise "Unknown key type #{ en_val.inspect }"
          end
        end

        # Merge missing keys
        merge! en_hash

        # Order alphabetically
        replace sort_by{ |k, v| k }.inject({}){ |h, a| h[a.first] = a.last; h }
      end
    end


    @engines.each do |c|
      path = "#{ c }/config/locales/"

      files = Dir[path + '*'].select{ |f| f =~ /\/\w+\.yml$/ }

      en = files.find{ |f| f =~ /\/en.yml$/ }
      files.delete(en)

      en_h = Psych.load_file(en)

      files.each do |f|
        h = Psych.load_file(f)

        # Leave language_name at the begining of the hash
        if c == "base"
          orig_h = h.first.last
          orig_en_h = en_h.first.last.dup

          language_name = orig_h.delete('language_name')
          language_name_en = orig_en_h.delete('language_name')
          language_name ||= language_name_en 

          orig_h.sync orig_en_h

          h.first.last.replace({ 'language_name' => language_name }.merge!(orig_h))
        else
          h.first.last.sync en_h.first.last
        end

        Psych.dump h, File.open(f, 'w')
      end

      Psych.dump en_h, File.open(en, 'w')
    end
  end

  desc "Write missing keys of i18n files"
  task "diff" => "common" do
    Hash.class_eval do
      def diff(en_hash)
        diff_hash = {}
        
        en_hash.each_key do |en_key|
          en_val   = en_hash[en_key]
          self_val = self[en_key]

          case en_val
          when NilClass
            # Do nothing
          when Hash
            if self_val.is_a?(Hash)
              diff = self_val.diff(en_val)

              if !diff.empty?
                diff_hash[en_key] = diff
              end
            else
              diff_hash[en_key] = en_val
            end
          when String
            if self_val.nil? || self_val == en_val
              diff_hash[en_key] = en_val
            end
          else
            raise "Unknown key type #{ en_val.inspect }"
          end
        end

        diff_hash
      end
    end

    @engines.each do |c|
      path = "#{ c }/config/locales/"

      files = Dir[path + '*'].select{ |f| f =~ /\/\w+\.yml$/ }

      en = files.find{ |f| f =~ /\/en.yml$/ }
      files.delete(en)

      en_h = Psych.load_file(en)

      files.each do |f|
        h = Psych.load_file(f)

        diff_hash = h.first.last.diff en_h.first.last

        if !diff_hash.empty?
          Psych.dump diff_hash, File.open("#{ f }.diff", 'w')
        end
      end
    end
  end
end
