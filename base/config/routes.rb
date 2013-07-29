Rails.application.routes.draw do
  root :to => "frontpage#index"
  
  match 'home' => 'home#index', :as => :home
  match 'home' => 'home#index', :as => :user_root # devise after_sign_in_path_for
  match 'explore(/:section)' => 'explore#index', :as => :explore
  match 'search' => 'search#index', :as => :search

  # Social Stream subjects configured in config/initializers/social_stream.rb
  route_subjects do
    resources :contacts
    resource :like
    resource :profile
    resources :activities

    # Nested Social Stream objects configured in config/initializers/social_stream.rb
    #
    # /users/demo/posts
    (SocialStream.objects - [ :actor ]).each do |object|
      resources object.to_s.pluralize do
        get 'search', :on => :collection
      end
    end

    # Repository models are configured in config/initializers/social_stream.rb
    if SocialStream.repository_models.present?
      resource :repository do
        get 'search', on: :collection
      end
    end
  end

  resources :actors, only: [ :index ]

  # Get information about current_subject
  match 'user'    => 'users#current', format: :json

  match 'profile' => 'profiles#show'

  # Social Stream objects configured in config/initializers/social_stream.rb
  #
  # /posts
  (SocialStream.objects - [ :actor ]).each do |object|
    resources object.to_s.pluralize do
      get 'search', :on => :collection
    end
  end

  resources :comments

  # Repository models are configured in config/initializers/social_stream.rb
  if SocialStream.repository_models.present?
    resource :repository do
      get 'search', on: :collection
    end
  end

  resources :contacts do
    collection do
      get 'suggestion'
      get 'pending'
    end
  end

  namespace "relation" do
    resources :customs
  end

  resources :permissions

  resources :activity_actions

  resource :representation
  
  resources :settings do
    collection do
      put 'update_all'
    end
  end

  resources :messages

  resources :conversations

  resources :invitations
  
  resources :notifications do
    collection do
      put 'update_all'
    end
  end

  resources :activities do
    resource :like
  end

  get 'home/activities' => 'activities#index', as: :home_activities, defaults: { section: 'home' }

  get 'audience/index', :as => :audience
  
  match 'ties' => 'ties#index', :as => :ties
  
  match 'tags' => 'tags#index', :as => 'tags'
  
  ##API###
  match 'api/keygen' => 'api#create_key', :as => :api_keygen
  match 'api/user/:id' => 'api#users', :as => :api_user
  match 'api/me' => 'api#users', :as => :api_me
  match 'api/me/home/' => 'api#activity_atom_feed', :format => 'atom', :as => :api_my_home

  match 'api/me/contacts' => 'contacts#index', :format => 'json', :as => :api_contacts
  ##/API##
 
  #Background tasks
  constraints SocialStream::Routing::Constraints::Resque.new do
    mount Resque::Server, :at => "/resque"
  end
end
