module SocialStream
  module Routing
    module Mapper

      # Route subjects configured as SocialStream.routed_subjects in
      # config/initializers/social_stream.rb
      #
      # It supports namespaces, so setting
      #
      #   SocialStream.routed_subjects = [ ':site/clients' ]
      #
      # and using
      #
      #   route_subjects do
      #     resources :posts
      #   end
      #
      # is equivalent to
      #
      #   namespace :site
      #     resources :clients
      #       resources :posts
      #     end
      #   end
      #  
      def route_subjects
        SocialStream.routed_subjects.each do |name|
          ns = name.to_s.split('/')
          actor = ns.pop

          rts = -> {
            resources actor.pluralize do
              yield
            end
          }

          if ns.present?
            ns.reverse.inject(rts) { |lmda, n|
              proc do
                namespace n, &lmda
              end
            }.call
          else
            rts.call
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, SocialStream::Routing::Mapper
