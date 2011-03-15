Rails.application.routes.draw do
  get "contacts/index"
  root :to => "frontpage#index"

  match 'home' => 'home#index', :as => :home
  match 'home' => 'home#index', :as => :user_root # devise after_sign_in_path_for

  resources :users

  resource :representation

  resources :groups
  
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
