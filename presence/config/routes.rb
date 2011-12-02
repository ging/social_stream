Rails.application.routes.draw do
  #match "/active_users" => "Xmpp#active_users"
  
  match '/xmpp/setConnection' => "Xmpp#setConnection"
  match '/xmpp/unsetConnection' => "Xmpp#unsetConecction"
  match '/xmpp/setPresence' => "Xmpp#setPresence"
  match '/xmpp/unsetPresence' => "Xmpp#unsetPresence"
  match '/xmpp/resetConnection' => "Xmpp#resetConnection"
  match '/xmpp/synchronizePresence' => "Xmpp#synchronizePresence"
  match '/xmpp/updateSettings'=> "Xmpp#updateSettings"
  match '/chatWindow'=> "Xmpp#chatWindow"
   
end