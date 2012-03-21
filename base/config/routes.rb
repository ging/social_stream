Rails.application.routes.draw do
  #Background tasks
  resque_constraint = lambda do |request|
    #request.env['warden'].authenticate? and request.env['warden'].user.admin?
    true
  end

  constraints resque_constraint do
    mount Resque::Server, :at => "/resque"
  end
  
  root :to => "frontpage#index"
  
  match 'home' => 'home#index', :as => :home
  match 'home' => 'home#index', :as => :user_root # devise after_sign_in_path_for
  
  # Webfinger
  match '.well-known/host-meta',:to => 'frontpage#host_meta'
  
  # Social Stream subjects configured in config/initializers/social_stream.rb
  SocialStream.subjects.each do |actor|
    resources actor.to_s.pluralize do
      resource :like
      resource :profile
      resources :activities

      # Nested Social Stream objects configured in config/initializers/social_stream.rb
      #
      # /users/demo/posts
      (SocialStream.objects - [ :actor ]).each do |object|
        resources object.to_s.pluralize
      end
    end
  end

  # Social Stream objects configured in config/initializers/social_stream.rb
  #
  # /posts
  (SocialStream.objects - [ :actor ]).each do |object|
    resources object.to_s.pluralize
  end

  case SocialStream.relation_model
  when :follow
    match 'followings' => 'followers#index', :as => :followings, :defaults => { :direction => 'sent' }
    match 'followers' => 'followers#index', :as => :followers, :defaults => { :direction => 'received' }
    resources :followers

    resources :contacts do
      collection do
        get 'pending'
      end
    end
  when :custom
    resources :contacts do
      collection do
        get 'pending'
      end
    end

    namespace "relation" do
      resources :customs
    end

    resources :permissions
  end

  resources :activity_actions

  match 'tags'     => 'tags#index', :as => 'tags'
  
  # Find subjects by slug
  match 'subjects/lrdd/:id' => 'subjects#lrdd', :as => 'subject_lrdd'
  
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

  resources :comments

  resources :activities do
    resource :like
  end
  
  match 'search' => 'search#index', :as => :search  
  
  match 'cheesecake' => 'cheesecake#index', :as => :cheesecake  
  match 'update_cheesecake' => 'cheesecake#update', :as => :update_cheesecake  
  
  match 'ties' => 'ties#index', :as => :ties
  
  
  ##API###
  match 'api/keygen' => 'api#create_key', :as => :api_keygen
  match 'api/user/:id' => 'api#users', :as => :api_user
  match 'api/me' => 'api#users', :as => :api_me
  match 'api/me/home/' => 'api#activity_atom_feed', :format => 'atom', :as => :api_my_home
  match 'api/user/:id/public' => 'api#activity_atom_feed', :format => 'atom', :as => :api_user_activities

  match 'api/me/contacts' => 'contacts#index', :format => 'json', :as => :api_contacts
  match 'api/subjects/:s/contacts' => 'contacts#index', :format => 'json', :as => :api_subject_contacts
  ##/API##
end
