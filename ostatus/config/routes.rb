Rails.application.routes.draw do
  # Host Meta
  match '/.well-known/host-meta', :to => HostMetaController.action(:index)

  # Webfinger
  match '/webfinger' => 'webfinger#index', :as => 'webfinger'

  # PushSubHubBub callback
  match 'pshb' => 'pshb#index', as: :pshb

  # Salmon callback
  match 'salmon/:slug' => 'salmon#index', as: :salmon
end
