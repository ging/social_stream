////////////////////
// Store and restore conversations using session storage.
////////////////////


function storeChatData(){
	
  //Check for Session Storage support
  if (! window.sessionStorage){
    return
  }
	
	storeUserChatStatus();
  storeChatConnectionParametres();
	storeConversations();
}

function storeConversations() {

  var chatboxes = getAllChatBoxes();
	var visibleChatBoxes = getVisibleChatBoxes();
	var storedSlugs = [];
	var visibleMaxSlugs = [];
	var visibleMinSlugs = [];
	
	//window[getChatVariableFromSlug("eric-white")].is(":visible")
	
	//Stored all conversations
	for (var i=0;i<chatboxes.length;i++){
	  var slug = chatboxes[i].id
	  var log = $(chatboxes[i]).html()
		sessionStorage.setItem("chat_log_" + slug, log);
		storedSlugs.push(slug)
	}
	
	if(storedSlugs.length>0){
		//Stored slugs with stored conversations
    sessionStorage.setItem("slugs_with_stored_log", storedSlugs.join(","));
	} else {
		sessionStorage.setItem("slugs_with_stored_log", null);
	}
	
	//Stored slugs with visible chatbox
	for (var j=0;j<visibleChatBoxes.length;j++){
		if(visibleChatBoxes[j].is(":visible")){
			visibleMaxSlugs.push($(visibleChatBoxes[j]).attr("id"))
		} else {
			visibleMinSlugs.push($(visibleChatBoxes[j]).attr("id"))
		}
  }
	
	if (visibleMaxSlugs.length > 0) {
  	sessionStorage.setItem("slugs_with_visible_max_chatbox", visibleMaxSlugs.join(","));
  } else {
		sessionStorage.setItem("slugs_with_visible_max_chatbox", null);
	}
	
	if (visibleMinSlugs.length > 0) {
    sessionStorage.setItem("slugs_with_visible_min_chatbox", visibleMinSlugs.join(","));
  } else {
    sessionStorage.setItem("slugs_with_visible_min_chatbox", null);
  }
}


function storeChatConnectionParametres() {
	if ((sessionStorage.getItem("cookie") == null)||(sessionStorage.getItem("chat_user_name") == null)){
		if ((typeof cookie != 'undefined')&&(cookie!=null)){
			sessionStorage.setItem("cookie", cookie);
		}
    if ((typeof user_name != 'undefined') && (user_name != null)) {
			sessionStorage.setItem("chat_user_name", user_name);
	  }
		if ((typeof user_slug != 'undefined') && (user_slug != null)) {
			sessionStorage.setItem("chat_user_slug", user_slug);
	  }
		if ((typeof user_jid != 'undefined') && (user_jid != null)) {
			sessionStorage.setItem("chat_user_jid", user_jid);
	  }
	}	
}

function storeUserChatStatus(){
	sessionStorage.setItem("chat_user_status", userStatus);
}

function removeAllDataStored(){
	sessionStorage.removeItem("cookie");
  sessionStorage.removeItem("chat_user_name");
  sessionStorage.removeItem("chat_user_slug");
  sessionStorage.removeItem("chat_user_jid");
	
	sessionStorage.removeItem("chat_user_status");
	
	sessionStorage.removeItem("slugs_with_stored_log");
	sessionStorage.removeItem("slugs_with_visible_max_chatbox");
	sessionStorage.removeItem("slugs_with_visible_min_chatbox");
}

function getRestoreUserChatStatus(){
	if (!window.sessionStorage) {
		return "available";
	}
	
	var restoreUserChatStatus = sessionStorage.getItem("chat_user_status");
	if ((restoreUserChatStatus != null)&&((restoreUserChatStatus in sstreamChatStatus)||(restoreUserChatStatus=="offline"))){
		return restoreUserChatStatus;
  } else {
		return "available";
	}
}


function restoreChatData(){
	
  //Check for Session Storage support
  if (! window.sessionStorage){
    return
  }
  restoreConversations();
}

function restoreConversations() {
	
	  //Get Stored slugs
	  var storedSlugsString = sessionStorage.getItem("slugs_with_stored_log");
		
		if (storedSlugsString != null){
			var storedSlugs=storedSlugsString.split(",")
			
			//Get slugs with visible chatbox
			var visibleMaxSlugsString = sessionStorage.getItem("slugs_with_visible_max_chatbox");
			var visibleMinSlugsString = sessionStorage.getItem("slugs_with_visible_min_chatbox");
			
			if(visibleMaxSlugsString!=null){
				var visibleMaxSlugs = visibleMaxSlugsString.split(",")
			} else {
				var visibleMaxSlugs = [];
			}
			
			if(visibleMinSlugsString!=null){
        var visibleMinSlugs = visibleMinSlugsString.split(",")
      } else {
        var visibleMinSlugs = [];
      }
			
			
			for (var i=0;i<storedSlugs.length;i++){
		    var restoreLog = sessionStorage.getItem("chat_log_" + storedSlugs[i]);
				
				if (restoreLog != null){

					//Create window (if it not exists)
					
					var guest_slug = storedSlugs[i];
					
					//Check for slug name and connectionBox visibility
				  if (typeof($('div.user_presence[slug=' + guest_slug + ']').attr('name')) == 'undefined') {
				    //No connectionBox for this user (user disconnect)
						var guest_name = getNameFromSlug(guest_slug)
				  } else {
				    var guest_name = $('div.user_presence[slug=' + guest_slug + ']').attr('name');
				  }
					 
          var guest_jid = guest_slug + "@" + domain;
					
					
					if (createChatBox(guest_slug, guest_name, guest_jid, user_name, user_jid)) {
						if ((visibleMinSlugs.indexOf(guest_slug)!=-1)){
							 //Minimize chatbox
							 window[getChatVariableFromSlug(guest_slug)].parent().toggle(false);
						}			
						if ((visibleMaxSlugs.indexOf(guest_slug)==-1)&&(visibleMinSlugs.indexOf(guest_slug)==-1)){
							closeChatBox(guest_slug); 
            }
          } else {
						//Always created.
          }
					
					window[getChatVariableFromSlug(guest_slug)].html(restoreLog)
					
					if (! isSlugChatConnected(guest_slug)) {
            showOfflineChatNotificationForSlug(guest_slug);
          }
					
        }
      }  	
		}  
}   



////////////////////
// Events
////////////////////

$(window).unload(function() {
	storeChatData();
	disconnectStrophe();
});