Rails.application.routes.draw do
  root :to => "frontpage#index"
  
  match 'home' => 'home#index', :as => :home
  match 'home' => 'home#index', :as => :user_root # devise after_sign_in_path_for
  
  ##API###
  match 'api/keygen' => 'api#create_key', :as => :api_keygen
  match 'api/user/:id' => 'api#users'
  match 'api/me' => 'api#users'
  match 'api/me/home/' => 'api#activity_atom_feed', :format => 'atom', :as => :api_my_home
  match 'api/user/:id/home' => 'api#activity_atom_feed', :format => 'atom'
  ##/API##
  
  # Webfinger
  match '.well-known/host-meta',:to => 'frontpage#host_meta'
  
  # Social Stream subjects configured in config/initializers/social_stream.rb
  SocialStream.subjects.each do |actor|
    resources actor.to_s.pluralize do
      resource :like
      resource :profile
      resources :activities
    end
  end

  match 'contacts' => 'contacts#index', :as => 'contacts'
  match 'tags'     => 'tags#index', :as => 'tags'
  
  # Find subjects by slug
  match 'subjects/lrdd/:id' => 'subjects#lrdd', :as => 'subject_lrdd'
  
  resource :representation
  
  resources :avatars

  resources :messages
  resources :conversations
  
  resources :ties do
    collection do
      get 'suggestion'
    end
  end
  
  resources :activities do
    resource :like
  end
  
  
  # Social Stream objects configured in config/initializers/social_stream.rb
  (SocialStream.objects - [ :actor ]).each do |object|
    resources object.to_s.pluralize
  end
end
