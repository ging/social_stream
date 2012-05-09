Rails.application.routes.draw do
  resources :pictures
  resources :audios
  resources :videos

  resources :documents do
    get "search",   :on => :collection
    get "download", :on => :member
  end
  
  # Social Stream subjects configured in config/initializers/social_stream.rb
  SocialStream.subjects.each do |actor|
    resources actor.to_s.pluralize do
      resources :pictures
      resources :audios
      resources :videos

      resources :documents do
        get "search",   :on => :collection
        get "download", :on => :member
      end
    end
  end
end
