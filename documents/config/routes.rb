Rails.application.routes.draw do
  # NOTE:
  # pictures,audios and video routes are already declared on social_stream/base/config/routes
  # there is not need to configure them here

  resources :documents do
    get "download", :on => :member
  end
  
  # Social Stream subjects configured in config/initializers/social_stream.rb
  SocialStream.subjects.each do |actor|
    resources actor.to_s.pluralize do
      resources :documents do
        get "download", :on => :member
      end
    end
  end
end
