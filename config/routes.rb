Rails.application.routes.draw do
  resources :pictures
  resources :audios
  resources :videos

  resources :documents do
    get "download", :on => :member
  end
end