Rails.application.routes.draw do
  devise_for :users
  resources :users

  match 'home' => 'home#index', :as => :home
  match 'home' => 'home#index', :as => :user_root # devise after_sign_in_path_for

  resources :groups

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

  root :to => "frontpage#index"
end
