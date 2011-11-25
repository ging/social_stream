Rails.application.routes.draw do
  #match "/active_users" => "Xmpp#active_users"
  
  match '/xmpp/resetConnection' => "Xmpp#resetConnection"
  match '/xmpp/setConnection' => "Xmpp#setConnection"
  match '/xmpp/unsetConnection' => "Xmpp#unsetConecction"
  match '/xmpp/synchronizePresence' => "Xmpp#synchronizePresence"
  match '/xmpp/setPresence' => "Xmpp#setPresence"
  match '/xmpp/unsetPresence' => "Xmpp#unsetPresence"
  match '/chatWindow'=> "Xmpp#chatWindow"
  match '/xmpp/updateSettings'=> "Xmpp#updateSettings"
   
end