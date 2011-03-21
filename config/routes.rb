Rails.application.routes.draw do
  get "contacts/index"
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
  
  resources :users
  
  resource :representation
  
  resources :groups
  resources :logos
    
  namespace :mailbox do 
    resources :conversation, :controller => :conversation 
  end
  resources :mailbox, :controller => :mailbox 
  
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
