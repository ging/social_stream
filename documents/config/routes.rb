Rails.application.routes.draw do
  resources :pictures
  resources :audios
  resources :videos

  match 'documents/original/:id(.:format)' => 'documents#original', :as => :original

  resources :documents do
    get "search",   :on => :collection
    get "download", :on => :member
  end

  # Social Stream subjects configured in config/initializers/social_stream.rb
  route_subjects do
    resources :pictures
    resources :audios
    resources :videos

    resources :documents do
      get "search",   :on => :collection
      get "download", :on => :member
    end
  end
end
