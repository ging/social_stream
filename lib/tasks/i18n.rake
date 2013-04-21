namespace :i18n do
  desc "Synchronize i18n files"
  task "sync" do
    require 'yaml'
    require 'social_stream/components'

    Hash.class_eval do
      def sync(h)
        en_hash = h.dup

        each_key do |self_key|
#          require 'debugger'; debugger
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
            raise "Unkown key type #{ en_val.inspect }"
          end
        end

        merge! en_hash
      end
    end

    SocialStream::ALL_COMPONENTS.each do |c|
      path = "#{ c }/config/locales/"
      files = Dir[path + '*'].select{ |f| f =~ /\/\w+\.yml$/ }
      en = files.find{ |f| f =~ /\/en.yml$/ }
      files.delete(en)
      en_h = Psych.load_file(en)

      files.each do |f|
        h = Psych.load_file(f)

        h.first.last.sync en_h.first.last

        Psych.dump h, File.open(f, 'w')
      end

      Psych.dump en_h, File.open(en, 'w')
    end
  end
end
