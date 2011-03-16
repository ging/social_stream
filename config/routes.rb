Rails.application.routes.draw do |map|
  get "contacts/index"
  root :to => "frontpage#index"
  
  match 'home' => 'home#index', :as => :home
  match 'home' => 'home#index', :as => :user_root # devise after_sign_in_path_for
  
  ##API###
  map.connect 'api/keygen', :controller => :api, :action => :create_key
  map.connect 'api/user/:id', :controller => :api, :action => :users
  map.connect 'api/me', :controller => :api, :action => :users
  ##/API##
  
  resources :users
  
  resource :representation
  
  resources :groups
  
  namespace :mailbox do 
    resources :conversation, :controller => :conversation 
  end
  resources :mailbox, :controller => :mailbox 
  #namespace :mailbox do resources :conversations end
  
  resources :ties do
    collection do
      get 'suggestion'
    end
  end
  
  resources :activities do
    resource :like
  end
  
  
  resources :posts
  resources :comments
end
