////////////////////
//Chat Boxes Notifications
////////////////////

function fadeInChatNotification(notification){
	if(notification!=null){
		notification.css("display","block");
    notification.css("visibility","visible");
    notification.fadeIn();
	}
}

function showChatNotification(notification,type,msg){
  notification.html("<p notification_type=\"" + type + "\" class=\"ui-chatbox-notify-text\">" + msg + "</p>");
  fadeInChatNotification(notification);
}

function showChatNotificationForSlug(slug,type,msg){
  var notification = $("#" + slug).parent().find("div.ui-chatbox-notify");
  if(notification.length==1){
    showChatNotification(notification,type,msg);
  }
}

function showOfflineChatNotificationForSlug(slug){
    var msg = I18n.t("chat.notify.guestOffline", {name: getNameFromSlug(slug)});
    showChatNotificationForSlug(slug,"guestOffline",msg);
}

function showVideoChatNotificationForSlug(slug,msg){
  showChatNotificationForSlug(slug,"videochat",msg);
}

function showVideoChatNotificationForSlugClientIssue(slug){
  var msg = I18n.t("chat.notify.videochat.clientIssue", {name: getNameFromSlug(slug)});
  showVideoChatNotificationForSlug(slug,msg);
}

function showVideoChatNotificationForSlugClientOffline(slug){
  var msg = I18n.t("chat.notify.videochat.offline", {name: getNameFromSlug(slug)});
  showVideoChatNotificationForSlug(slug,msg);
}

function fadeOutChatNotification(notification){
	if(notification!=null){
		notification.fadeOut();
    notification.css("display","none");
    notification.css("visibility","hidden");
	}
}

function hideChatNotificationForSlug(slug){
  var notification = getChatNotificationForSlug(slug);
  fadeOutChatNotification(notification);
}

function updateNotificationsAfterUserDisconnect(){
  var notification = $("div.ui-chatbox-notify");
  var msg = I18n.t('chat.notify.offline');
  showChatNotification(notification,"userOffline",msg);
}

function hideAllNotifications(){
  var notification = $("div.ui-chatbox-notify");
  fadeOutChatNotification(notification);
}

function updateAllNotifications(){
  hideAllNotifications();
  if(disconnectionFlag){
    updateNotificationsAfterUserDisconnect();
  } else {
    //Notification for offline contacts
    $.each(getAllDisconnectedSlugsWithChatBoxes(), function(index, value) {
      if(!isSlugGroup(value)){
        showOfflineChatNotificationForSlug(value)
      }
    }); 
  }
}

function getChatNotificationForSlug(slug){
  var chatBox = getChatBoxForSlug(slug)
  if(chatBox!=null){
    var notification = chatBox.parent().find("div.ui-chatbox-notify");
    if (notification.length == 1) {
      return notification;
    }
  }
  return null;
}

function getNotificationType(notification){
  return $(notification).find("p").attr("notification_type");
}

function addTextToNotification(notification,txt,type,name){
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

function removeTextFromNotification(notification,name){
  var p = $(notification).find("p.ui-chatbox-notify-text[name=" + name + "]")
  if (p!=null){
    p.remove()
		var empty = ($(notification).find("p").length==0)
		if (empty){
			fadeOutChatNotification(notification)
		}
  }
}

function removeAllTextsFromNotification(notification){
  var p = $(notification).find("p.ui-chatbox-notify-text")
  if (p!=null){
    p.remove()
    var empty = ($(notification).find("p").length==0)
    if (empty){
      fadeOutChatNotification(notification)
    }
  }
}

function addTextToNotificationForSlug(slug,txt,type,name){
  var notification = getChatNotificationForSlug(slug);
  if(notification!=null){
    addTextToNotification(notification,txt,type,name)
  }
}

function removeTextFromNotificationForSlug(slug,name){
  var notification = getChatNotificationForSlug(slug);
  if(notification!=null){
    removeTextFromNotification(notification,name)
  }
}

function removeAllTextsFromNotificationForSlug(slug){
  var notification = getChatNotificationForSlug(slug);
  if(notification!=null){
    removeAllTextsFromNotification(notification)
  }
}


////////////////////////
// Group notifications
///////////////////////

function addNickToNotificationInGroup(roomName,nick){
  if(isSlugGroup(roomName)){
    addTextToNotificationForSlug(roomName,nick,"roomNotification",nick)
  }
}

function removeNickFromNotificationInGroup(roomName,nick){
  if(isSlugGroup(roomName)){
		removeTextFromNotificationForSlug(roomName,nick)
  }
}

function initialNotificationInGroup(roomName,msg){
	removeAllTextsFromNotificationForSlug(roomName);
  addTextToNotificationForSlug(roomName,msg,"roomNotification","Initial_Notification")
}

function changeInitialNotificationInGroup(roomName,msg){
	var notification = getChatNotificationForSlug(roomName);
	if(notification!=null){
		$(notification).find("p.ui-chatbox-notify-text[name=" + "Initial_Notification" + "]").html(msg)
	}
}


////////////////////
//Events
////////////////////

function onClickChatNotification(notification){
	if (getNotificationType(notification)=="roomNotification"){
		return;
	}
	fadeOutChatNotification(notification)
}
