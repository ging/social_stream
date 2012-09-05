Rails.application.routes.draw do
  # Webfinger
  match '/.well-known/host-meta', :to => HostMetaController.action(:index)

  # Find subjects by slug
  match '/webfinger' => 'webfinger#index', :as => 'webfinger'

  match 'pshb/callback' => 'pshb#callback', :as => :pshb_callback
  match 'remoteuser/' => 'remoteusers#index', :as => :add_remote_user
end
