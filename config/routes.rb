Rails.application.routes.draw do
  devise_for :users
  resources :users
  resources :groups

  match 'home' => 'home#index', :as => :home

  resources :ties
  resources :activities do
    resource :like
  end
  resources :posts
  resources :comments
end
