module SocialStream
  module Search
    class << self
      def keys(search_type)
        case search_type
        when :quick
          SocialStream.quick_search_models
        when :extended
          extended_search_models.keys
        end
      end

      def models(search_type, key = nil)
        case search_type
        when :quick
          quick_search_models
        when :extended
          if key
            if extended_search_models.keys.include?(key.to_sym)
              extended_search_models[key.to_sym]
            else
              if extended_search_models.values.flatten.map{ |k| k.to_s }.include?(key.to_s.classify)
                [key.to_s.classify.constantize]
              else
                debugger
                puts ""
                raise "Unknown search key #{ key }"
              end
            end
          else
            extended_search_models.values.flatten
          end
        else
          raise "Unknown search type #{ search_type }"
        end
      end

      private

      def quick_search_models
        @quick_search_models ||=
          parse_quick_search_models
      end

      def parse_quick_search_models
        SocialStream.quick_search_models.map{ |m|
          m.to_s.classify.constantize
        }
      end

      def extended_search_models
        @extended_search_models ||=
          parse_extended_search_models 
      end

      # Get a normalized hash from the configuration. Converts this:
      #
      #   [ :excursion, :user, { :resource => [ :post, :comment, :picture ] }
      #
      # into this:
      #
      #   {
      #     :excursion => [ Excursion ],
      #     :user => [ User ],
      #     :resource => [ Post, Comment, Picture ]
      #   }
      #
      def parse_extended_search_models
          SocialStream.extended_search_models.inject({}) do |hash, entry|
            case entry
            when Hash
              hash.update entry.inject({}){ |h, e|
                h[e.first] = Array.wrap(e.last).map{ |f| f.to_s.classify.constantize }
                h
              }
            when Symbol
              hash[entry] = Array.wrap(entry.to_s.classify.constantize)
            else
              raise "Unknown entry in config.extended_search_models #{ entry }"
            end

            hash
          end
      end
    end
  end
end
