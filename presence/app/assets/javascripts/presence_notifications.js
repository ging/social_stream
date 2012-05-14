PRESENCE.NOTIFICATIONS = (function(P,$,undefined){

  var init = function(){ }


	////////////////////
	//Chat Boxes Notifications
	////////////////////
	
	var fadeInChatNotification = function(notification){
	  if(notification!=null){
	    notification.css("display","block");
	    notification.css("visibility","visible");
	    notification.fadeIn();
	  }
	}
	
	var showChatNotification = function(notification,type,msg){
	  notification.html("<p notification_type=\"" + type + "\" class=\"ui-chatbox-notify-text\">" + msg + "</p>");
	  fadeInChatNotification(notification);
	}
	
	var showChatNotificationForSlug = function(slug,type,msg){
	  var notification = $("#" + slug).parent().find("div.ui-chatbox-notify");
	  if(notification.length==1){
	    showChatNotification(notification,type,msg);
	  }
	}
	
	var showOfflineChatNotificationForSlug = function(slug){
	    var msg = I18n.t("chat.notify.guestOffline", {name: PRESENCE.XMPPClient.getNameFromSlug(slug)});
	    showChatNotificationForSlug(slug,"guestOffline",msg);
	}
	
	var showVideoChatNotificationForSlug = function(slug,msg){
	  showChatNotificationForSlug(slug,"videochat",msg);
	}
	
	var showVideoChatNotificationForSlugClientIssue = function(slug){
	  var msg = I18n.t("chat.notify.videochat.clientIssue", {name: PRESENCE.XMPPClient.getNameFromSlug(slug)});
	  showVideoChatNotificationForSlug(slug,msg);
	}
	
	var showVideoChatNotificationForSlugClientOffline = function(slug){
	  var msg = I18n.t("chat.notify.videochat.offline", {name: PRESENCE.XMPPClient.getNameFromSlug(slug)});
	  showVideoChatNotificationForSlug(slug,msg);
	}
	
	var fadeOutChatNotification = function(notification){
	  if(notification!=null){
	    notification.fadeOut();
	    notification.css("display","none");
	    notification.css("visibility","hidden");
	  }
	}
	
	var hideChatNotificationForSlug = function(slug){
	  var notification = getChatNotificationForSlug(slug);
	  fadeOutChatNotification(notification);
	}
	
	var updateNotificationsAfterUserDisconnect = function(){
	  var notification = $("div.ui-chatbox-notify");
	  var msg = I18n.t('chat.notify.offline');
	  showChatNotification(notification,"userOffline",msg);
	}
	
	var hideAllNotifications = function(){
	  var notification = $("div.ui-chatbox-notify");
	  fadeOutChatNotification(notification);
	}
	
	var updateAllNotifications = function(){
	  hideAllNotifications();
	  if(PRESENCE.XMPPClient.getDisconnectionFlag()){
	    updateNotificationsAfterUserDisconnect();
	  } else {
	    //Notification for offline contacts
	    $.each(PRESENCE.WINDOW.getAllDisconnectedSlugsWithChatBoxes(), function(index, value) {
	      if(!PRESENCE.WINDOW.isSlugGroup(value)){
	        showOfflineChatNotificationForSlug(value)
	      }
	    }); 
	  }
	}
	
	var getChatNotificationForSlug = function(slug){
	  var chatBox = PRESENCE.WINDOW.getChatBoxForSlug(slug)
	  if(chatBox!=null){
	    var notification = chatBox.parent().find("div.ui-chatbox-notify");
	    if (notification.length == 1) {
	      return notification;
	    }
	  }
	  return null;
	}
	
	var getNotificationType = function(notification){
	  return $(notification).find("p").attr("notification_type");
	}
	
	var addTextToNotification = function(notification,txt,type,name){
	  var new_p = document.createElement('p')
	  $(new_p).attr("class","ui-chatbox-notify-text")
	  $(new_p).attr("notification_type",type)
	  $(new_p).html(txt)
	  if(name!=null){
	    $(new_p).attr("name",name)
	  }
	  $(notification).append(new_p)
	  fadeInChatNotification(notification)
	}
	
	var removeTextFromNotification = function(notification,name){
	  var p = $(notification).find("p.ui-chatbox-notify-text[name=" + name + "]")
	  if (p!=null){
	    p.remove()
	    var empty = ($(notification).find("p").length==0)
	    if (empty){
	      fadeOutChatNotification(notification)
	    }
	  }
	}
	
	var removeAllTextsFromNotification = function(notification){
	  var p = $(notification).find("p.ui-chatbox-notify-text")
	  if (p!=null){
	    p.remove()
	    var empty = ($(notification).find("p").length==0)
	    if (empty){
	      fadeOutChatNotification(notification)
	    }
	  }
	}
	
	var addTextToNotificationForSlug = function(slug,txt,type,name){
	  var notification = getChatNotificationForSlug(slug);
	  if(notification!=null){
	    addTextToNotification(notification,txt,type,name)
	  }
	}
	
	var removeTextFromNotificationForSlug = function(slug,name){
	  var notification = getChatNotificationForSlug(slug);
	  if(notification!=null){
	    removeTextFromNotification(notification,name)
	  }
	}
	
	var removeAllTextsFromNotificationForSlug = function(slug){
	  var notification = getChatNotificationForSlug(slug);
	  if(notification!=null){
	    removeAllTextsFromNotification(notification)
	  }
	}
	
	
	////////////////////////
	// Group notifications
	///////////////////////
	
	var addNickToNotificationInGroup = function(roomName,nick){
	  if(PRESENCE.WINDOW.isSlugGroup(roomName)){
	    addTextToNotificationForSlug(roomName,nick,"roomNotification",nick)
	  }
	}
	
	var removeNickFromNotificationInGroup = function(roomName,nick){
	  if(PRESENCE.WINDOW.isSlugGroup(roomName)){
	    removeTextFromNotificationForSlug(roomName,nick)
	  }
	}
	
	var initialNotificationInGroup = function(roomName,msg){
	  removeAllTextsFromNotificationForSlug(roomName);
	  addTextToNotificationForSlug(roomName,msg,"roomNotification","Initial_Notification")
	}
	
	var changeInitialNotificationInGroup = function(roomName,msg){
	  var notification = getChatNotificationForSlug(roomName);
	  if(notification!=null){
	    $(notification).find("p.ui-chatbox-notify-text[name=" + "Initial_Notification" + "]").html(msg)
	  }
	}
	
	
	////////////////////
	//Events
	////////////////////
	
	var onClickChatNotification = function(notification){
	  if (getNotificationType(notification)=="roomNotification"){
	    return;
	  }
	  fadeOutChatNotification(notification)
	}
	  


  return {
    init: init,
		showOfflineChatNotificationForSlug : showOfflineChatNotificationForSlug,
		hideChatNotificationForSlug : hideChatNotificationForSlug,
		updateNotificationsAfterUserDisconnect : updateNotificationsAfterUserDisconnect,
		updateAllNotifications : updateAllNotifications,
		addNickToNotificationInGroup : addNickToNotificationInGroup,
		removeNickFromNotificationInGroup : removeNickFromNotificationInGroup,
		initialNotificationInGroup : initialNotificationInGroup,
		changeInitialNotificationInGroup : changeInitialNotificationInGroup,
		onClickChatNotification : onClickChatNotification
  };

}) (PRESENCE, jQuery);

