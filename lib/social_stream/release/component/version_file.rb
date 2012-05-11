module SocialStream
  module Release
    class Component
      class VersionFile < Global::VersionFile
        attr_reader :name

        def initialize(name, target = nil)
          @name = name
          super(target)
        end

        def filename
          "#{ name }/lib/social_stream/#{ name }/version.rb"
        end
      end
    end
  end
end
