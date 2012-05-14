////////////////////
// Store and restore conversations using session storage.
////////////////////

function storeChatData(){
	
  //Check for Session Storage support
  if (! window.sessionStorage){
    return
  }
	
	storeChatStatus();
	storeUserChatStatus();
	storeConversations();
}

function storeChatStatus(){
	//Status of the mainChatBoxWindow
  if(mainChatBox!=null){
    sessionStorage.setItem("chat_mainChatBox_status", $(mainChatBox).is(":visible"));
  } else {
    sessionStorage.setItem("chat_mainChatBox_status", null);
  } 
}

function storeConversations() {
  var chatboxes = getAllChatBoxes();
	var visibleChatBoxes = getVisibleChatBoxes();
	var storedSlugs = [];
	var storedGroupSlugs = [];
	var visibleMaxSlugs = [];
	var visibleMinSlugs = [];
	
	//Stored all conversations
	for (var i=0;i<chatboxes.length;i++){
	  var slug = chatboxes[i].id
		if(isSlugGroup(slug)){
			if(visibleChatBoxes.indexOf(getChatBoxForSlug(slug))!=-1){
				storedGroupSlugs.push(slug)
			}
    } else {
      var log = $(chatboxes[i]).html()
      sessionStorage.setItem("chat_log_" + slug, log);
      storedSlugs.push(slug)
    }
	}
	
	if(storedSlugs.length>0){
		//Stored slugs with stored conversations
    sessionStorage.setItem("slugs_with_stored_log", storedSlugs.join(","));
	} else {
		sessionStorage.setItem("slugs_with_stored_log", null);
	}
	
	if(storedGroupSlugs.length>0){
    //Stored open groups slugs
    sessionStorage.setItem("open_group_slugs", storedGroupSlugs.join(","));
  } else {
    sessionStorage.setItem("open_group_slugs", null);
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

function storeUserChatStatus(){
	sessionStorage.setItem("chat_user_status", userStatus);
}

function removeAllDataStored(){
	sessionStorage.removeItem("chat_user_status");
	sessionStorage.removeItem("chat_mainChatBox_status");
	
	sessionStorage.removeItem("slugs_with_stored_log");
	sessionStorage.removeItem("slugs_with_visible_max_chatbox");
	sessionStorage.removeItem("slugs_with_visible_min_chatbox");
	sessionStorage.removeItem("open_group_slugs");
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

	restoreChatBoxes();
}

function getRestoreMainChatBoxStatus(){
	if (!window.sessionStorage) {
    return false;
  } else {
		if(sessionStorage.getItem("chat_mainChatBox_status") == "true"){
			return true;
		} else {
			return false;
		}
	}
}

function restoreChatBoxes(){
	
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

	restoreBuddyChatBoxes(visibleMaxSlugs,visibleMinSlugs);
  restoreGroupsChatBoxes(visibleMaxSlugs,visibleMinSlugs);
}

function restoreGroupsChatBoxes(visibleMaxSlugs,visibleMinSlugs){
	var groupSlugsString = sessionStorage.getItem("open_group_slugs")
	if((groupSlugsString != null)&&(groupSlugsString != "null")){
		var groupSlugs=groupSlugsString.split(",")
		
		for (var i=0;i<groupSlugs.length;i++){    
      var guest_slug = groupSlugs[i]
      var guest_name = getNameFromSlug(guest_slug)
			var open = (visibleMinSlugs.indexOf(guest_slug)==-1)
			accessRoom(guest_slug,open)
    }
	}
}

function restoreBuddyChatBoxes(visibleMaxSlugs,visibleMinSlugs) {
  //Get Stored slugs
  var storedSlugsString = sessionStorage.getItem("slugs_with_stored_log");
	
	if (storedSlugsString != null){
		var storedSlugs=storedSlugsString.split(",")

		for (var i=0;i<storedSlugs.length;i++){
	    var restoreLog = sessionStorage.getItem("chat_log_" + storedSlugs[i]);
			
			if (restoreLog != null){

				var guest_slug = storedSlugs[i];
				var guest_name = getNameFromSlug(guest_slug)
        var guest_jid = guest_slug + "@" + domain;
				createBuddyChatBox(guest_slug)
				
				if ((visibleMinSlugs.indexOf(guest_slug)!=-1)){
					 //Minimize chatbox
					 window[getChatVariableFromSlug(guest_slug)].parent().toggle(false);
				}			
				if ((visibleMaxSlugs.indexOf(guest_slug)==-1)&&(visibleMinSlugs.indexOf(guest_slug)==-1)){
					closeChatBox(guest_slug); 
        }
				
				getChatBoxForSlug(guest_slug).html(restoreLog)
				
				if (! isSlugChatConnected(guest_slug)) {
          showOfflineChatNotificationForSlug(guest_slug);
        }
				
      }
    }  	
	}  
}   


