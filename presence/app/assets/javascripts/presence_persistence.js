PRESENCE.PERSISTENCE = (function(P,$,undefined){

  var init = function(){ }


	////////////////////
	// Store and restore conversations using session storage.
	////////////////////
	
	var storeChatData = function(){
	  
	  //Check for Session Storage support
	  if (! window.sessionStorage){
	    return
	  }
	  
	  storeChatStatus();
	  storeUserChatStatus();
	  storeConversations();
	}
	
	var storeChatStatus = function(){
	  //Status of the mainChatBoxWindow
		var mainChatBox = PRESENCE.WINDOW.getMainChatBox();
	  if(mainChatBox!=null){
	    sessionStorage.setItem("chat_mainChatBox_status", $(mainChatBox).is(":visible"));
	  } else {
	    sessionStorage.setItem("chat_mainChatBox_status", null);
	  } 
	}
	
	var storeConversations = function() {
	  var chatboxes = PRESENCE.WINDOW.getAllChatBoxes();
	  var pvisibleChatBoxes = PRESENCE.WINDOW.getVisibleChatBoxes();
	  var storedSlugs = [];
	  var storedGroupSlugs = [];
	  var visibleMaxSlugs = [];
	  var visibleMinSlugs = [];
	  
	  //Stored all conversations
	  for (var i=0;i<chatboxes.length;i++){
	    var slug = chatboxes[i].id
	    if(PRESENCE.WINDOW.isSlugGroup(slug)){
	      if(pvisibleChatBoxes.indexOf(PRESENCE.WINDOW.getChatBoxForSlug(slug))!=-1){
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
	  for (var j=0;j<pvisibleChatBoxes.length;j++){
	    if(pvisibleChatBoxes[j].is(":visible")){
	      visibleMaxSlugs.push($(pvisibleChatBoxes[j]).attr("id"))
	    } else {
	      visibleMinSlugs.push($(pvisibleChatBoxes[j]).attr("id"))
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
	
	var storeUserChatStatus = function(){
	  sessionStorage.setItem("chat_user_status", PRESENCE.XMPPClient.getUserStatus());
	}
	
	var removeAllDataStored = function(){
	  sessionStorage.removeItem("chat_user_status");
	  sessionStorage.removeItem("chat_mainChatBox_status");
	  
	  sessionStorage.removeItem("slugs_with_stored_log");
	  sessionStorage.removeItem("slugs_with_visible_max_chatbox");
	  sessionStorage.removeItem("slugs_with_visible_min_chatbox");
	  sessionStorage.removeItem("open_group_slugs");
	}
	
	var getRestoreUserChatStatus = function(){
	  if (!window.sessionStorage) {
	    return "available";
	  }
	  
	  var restoreUserChatStatus = sessionStorage.getItem("chat_user_status");
	  if ((restoreUserChatStatus != null)&&((restoreUserChatStatus in PRESENCE.XMPPClient.getSStreamChatStatus())||(restoreUserChatStatus=="offline"))){
	    return restoreUserChatStatus;
	  } else {
	    return "available";
	  }
	}
	
	var restoreChatData = function(){
	  
	  //Check for Session Storage support
	  if (! window.sessionStorage){
	    return
	  }
	
	  restoreChatBoxes();
	}
	
	var getRestoreMainChatBoxStatus = function(){
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
	
	var restoreChatBoxes = function(){
	  
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
	
	var restoreGroupsChatBoxes = function(visibleMaxSlugs,visibleMinSlugs){
	  var groupSlugsString = sessionStorage.getItem("open_group_slugs")
	  if((groupSlugsString != null)&&(groupSlugsString != "null")){
	    var groupSlugs=groupSlugsString.split(",")
	    
	    for (var i=0;i<groupSlugs.length;i++){    
	      var guest_slug = groupSlugs[i]
	      var guest_name = PRESENCE.XMPPClient.getNameFromSlug(guest_slug)
	      var open = (visibleMinSlugs.indexOf(guest_slug)==-1)
	      PRESENCE.XMPPClient.accessRoom(guest_slug,open)
	    }
	  }
	}
	
	var restoreBuddyChatBoxes = function(visibleMaxSlugs,visibleMinSlugs) {
	  //Get Stored slugs
	  var storedSlugsString = sessionStorage.getItem("slugs_with_stored_log");
	  
	  if (storedSlugsString != null){
	    var storedSlugs=storedSlugsString.split(",")
	
	    for (var i=0;i<storedSlugs.length;i++){
	      var restoreLog = sessionStorage.getItem("chat_log_" + storedSlugs[i]);
	      
	      if (restoreLog != null){
	
	        var guest_slug = storedSlugs[i];
	        var guest_name = PRESENCE.XMPPClient.getNameFromSlug(guest_slug)
	        var guest_jid = PRESENCE.XMPPClient.getJidFromSlug(guest_slug);
	        PRESENCE.WINDOW.createBuddyChatBox(guest_slug)
	        
	        if ((visibleMinSlugs.indexOf(guest_slug)!=-1)){
	           //Minimize chatbox
						 PRESENCE.WINDOW.getChatBoxForSlug(guest_slug).parent().toggle(false);
	        }     
	        if ((visibleMaxSlugs.indexOf(guest_slug)==-1)&&(visibleMinSlugs.indexOf(guest_slug)==-1)){
	          PRESENCE.WINDOW.closeChatBox(guest_slug); 
	        }
	        
	        PRESENCE.WINDOW.getChatBoxForSlug(guest_slug).html(restoreLog)
	        
	        if (! PRESENCE.UIMANAGER.isSlugChatConnected(guest_slug)) {
	          PRESENCE.NOTIFICATIONS.showOfflineChatNotificationForSlug(guest_slug);
	        }
	        
	      }
	    }   
	  }  
	}   


  return {
    init: init,
		storeChatData : storeChatData,
		restoreChatData : restoreChatData,
		getRestoreUserChatStatus : getRestoreUserChatStatus,
		getRestoreMainChatBoxStatus : getRestoreMainChatBoxStatus
  };

}) (PRESENCE, jQuery);




