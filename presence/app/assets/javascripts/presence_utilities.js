////////////////////
//SOCIAL STREAM PRESENCE: UTILITIES
////////////////////

PRESENCE.UTILITIES = (function(P,$,undefined){

  var init = function(){ 
	  initFocusListeners();
	}

	////////////////////
	//Debug functions
	////////////////////
	var debugging=false;
	
	var log = function(msg) {
	    if(debugging){
	      console.log(msg)
	    } 
	}
	
	////////////////////
	//Blink page title when focus lost on new messages
	////////////////////
	var chatFocus;
	
	var onChatBlur = function() {
	  chatFocus = false;
	};
	
	var onChatFocus = function(){
	  stopBlink();
	  titles = []; //Remove titles after StopBlink!
	  chatFocus = true;
	};
	
	var initFocusListeners = function(){
	  if (/*@cc_on!@*/false) { // check for Internet Explorer
	    document.onfocusin = PRESENCE.UTILITIES.onChatFocus;
	    document.onfocusout = PRESENCE.UTILITIES.onChatBlur;
	  } else {
	    window.onfocus = PRESENCE.UTILITIES.onChatFocus;
	    window.onblur =  PRESENCE.UTILITIES.onChatBlur;
	  }
	}
	
	var getChatFocus = function(){
		return chatFocus;
	}	
	
	
	var blinkTimer;
	var titles=[];
	
	var blinkTitle = function(titles,index){
	  $(document).attr("title", titles[index]);
	  index = (index+1)%titles.length
	  blinkTimer=setTimeout(function(){PRESENCE.UTILITIES.blinkTitle(titles,index)}, 2000);
	}
	
	var stopBlink = function (){
	  clearTimeout(blinkTimer);
	  if (titles.length > 0) {
	    $(document).attr("title", titles[0]);
	  }
	}
	
	var blinkTitleOnMessage = function (username){
	  if (!chatFocus){
	    if (titles.length==0){
	      titles.push($(document).attr("title"))
	    }
	    if (titles.indexOf(username) == -1){
	      titles.push(username + " says...")
	    }
	    stopBlink();
	    blinkTitle(titles,titles.length-1);
	  }
	}
	
	
	
	////////////////////
	//Control user data input on the chatbox
	////////////////////
	
	//Return true to allow user to send data to the chatbox.
	var userChatDataInputControl = function(){
	  var floodControlBoolean = floodControl();
	  var offlineDataSendControlBoolean = offlineDataSendControl();
	  return (floodControlBoolean && offlineDataSendControlBoolean);
	}
	
	
	
	////////////////////
	//Antiflood
	////////////////////
	
	var lastMessageTimes = new Array();
	//lastMessageTimes['slug'] = ["timeOfLastMessage",["msgID1","msgID2"]];
	
	var timeBetweenMessages = 500; //mseconds
	
	//Return true when detects a text storm and control the text flood:
	//timeBetweenMessages is the minimum time that must elapse between the messages of the same contact.
	var antifloodControl = function(from_slug,msg,msgID) {

	  if( from_slug in lastMessageTimes){
	
	  } else {
	    lastMessageTimes[from_slug] = [,[]];
	  }
	  
	  if (msgID==null){
	    msgID = generateMessageID();
	  }
	  
	  var lastMessageTime = lastMessageTimes[from_slug][0];
	  
	  var t = (new Date()).getTime();
	  if(t - lastMessageTime < timeBetweenMessages) {
	     //Flood detected
	     return retryToShowMessage(from_slug,msg,msgID);
	  }
	  
	  //Check if is the first message of this user to be send.
	  //var messageQueue = lastMessageTimes[from_slug][1];
	  
	  if (lastMessageTimes[from_slug][1].length>0){
	    if((lastMessageTimes[from_slug][1])[0]==msgID){
	      //Message is the first on the queue: Show it and remove from the queue
	      lastMessageTimes[from_slug][1].splice(0,1);
	    } else {
	      //Message is not the first on the queue
	      return retryToShowMessage(from_slug,msg,msgID);
	    }
	  }
	  
	  //Message can be send
	  lastMessageTimes[from_slug][0] = t; 
	  return false;
	};
	
	
	var rootMessageID=1;
	var generateMessageID = function(){
	  return (++rootMessageID);
	}
	
	
	var retryToShowMessage = function(from_slug,msg,msgID){
	  //Enque the message if isn't in the queue
	  if (lastMessageTimes[from_slug][1].indexOf(msgID)==-1){
	    lastMessageTimes[from_slug][1].push(msgID);
	  }
	      
	  setTimeout(function(){PRESENCE.UIMANAGER.afterReceivedChatMessage(from_slug,msg,msgID)}, timeBetweenMessages);
	  return true;
	}

	
	////////////////////
	//Controlflood
	////////////////////
	var timeBetweenOwnMessages = 500; //mseconds
	var lastMessageSentTime=null;
	
	var floodControl = function() {
	  var t = (new Date()).getTime();
	  
	  if(lastMessageSentTime==null){
	    lastMessageSentTime = t;
	    return true;
	  }
	  
	  if (t - lastMessageSentTime < timeBetweenOwnMessages) {
	    return false;
	  } else {
	    lastMessageSentTime = t;
	    return true;
	  } 
  };


	////////////////////
	//Bounce chatbox control
	////////////////////
	var lastBounceTimes = new Array();
	var timeBetweenBounces = 5000; //mseconds
	
	var mustBounceBoxForChatWindow = function(jqueryUIChatbox){
	  
	  var slug = jqueryUIChatbox.elem.uiChatbox.find(".ui-chatbox-content").find(".ui-chatbox-log").attr("id")
	  
	  if (typeof slug == 'undefined') {
	    return false;
	  }
	  
	  if((slug in contactsInfo)&&(contactsInfo[slug].videoChatStatus!="disconnected")){
	      return false;
	  }
	
	  var t = (new Date()).getTime();
	  
	  if(!(slug in lastBounceTimes)){
	    lastBounceTimes[slug] = t;
	    return true;
	  }
	   
	  var lastBounceTime = lastBounceTimes[slug];
	  
	  if (t - lastBounceTime < timeBetweenBounces) {
	    return false;
	  } else {
	    lastBounceTimes[slug] = t;
	    return true;
	  } 
	  
	}
	
	
	
	////////////////////
	//Prevent user to send data to the chatbox when he is offline.
	////////////////////
	
	var offlineDataSendControl = function(){
	  return ((!PRESENCE.XMPPClient.getDisconnectionFlag()) && (PRESENCE.XMPPClient.isStropheConnected()));
	}
	
	
	////////////////////
	//Special slugs management
	////////////////////
	var isAdminSlug = function(slug){
	  return (slug == '<%=SocialStream::Presence.social_stream_presence_username%>');
	}
	
	
	////////////////////
	//Next features...
	////////////////////
  //[...]


  return {
    init: init,
		log : log,
		onChatFocus : onChatFocus,
		onChatBlur : onChatBlur,
		blinkTitleOnMessage : blinkTitleOnMessage,
		blinkTitle : blinkTitle,
		userChatDataInputControl : userChatDataInputControl,
		antifloodControl : antifloodControl,
		mustBounceBoxForChatWindow : mustBounceBoxForChatWindow,
		isAdminSlug : isAdminSlug,
		getChatFocus : getChatFocus
  };


}) (PRESENCE, jQuery);
