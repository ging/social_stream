////////////////////
//Test functions
////////////////////

function log(msg) {
    //console.log(msg)
}

function simulate_new_user_connected(slug) {
  var stanza_test = '<presence xmlns="jabber:client" from="' + slug + '@localhost/27825459741328802387991286" to="demo@localhost/2517285379132880233667729">'
  onPresence(stanza_test);
}

function simulate_new_user_disconnected(slug) {
  var stanza_test = '<presence xmlns="jabber:client" type="unavailable" from="' + slug + '@localhost/27825459741328802387991286" to="demo@localhost/2517285379132880233667729">'
  onPresence(stanza_test);
}


////////////////////
//Blink page title when focus lost on new messages
////////////////////

var chatFocus;

function onChatBlur() {
  chatFocus = false;
};

function onChatFocus(){
  stopBlink();
  titles = []; //Remove titles after StopBlink!
  chatFocus = true;
};

function initFocusListeners(){
  if (/*@cc_on!@*/false) { // check for Internet Explorer
    document.onfocusin = onFocus;
    document.onfocusout = onBlur;
  } else {
    window.onfocus = onChatFocus;
    window.onblur =  onChatBlur;
  }
}


var blinkTimer;
var titles=[];

function blinkTitle(titles,index){
  $(document).attr("title", titles[index]);
  index = (index+1)%titles.length
  blinkTimer=setTimeout(function(){blinkTitle(titles,index)}, 2000);
}

function stopBlink(){
  clearTimeout(blinkTimer);
  if (titles.length > 0) {
    $(document).attr("title", titles[0]);
  }
}

function blinkTitleOnMessage(username){
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
function userChatDataInputControl(){
	var floodControlBoolean = floodControl();
  var offlineDataSendControlBoolean = offlineDataSendControl();
	return (floodControlBoolean && offlineDataSendControlBoolean);
}



////////////////////
//Antiflood
////////////////////

var lastMessageTimes = new Array();
//lastMessageTimes['from_slug'] = ["timeOfLastMessage",["msgID1","msgID2"]];

var timeBetweenMessages = 500; //mseconds

//Return true when detects a text storm and control the text flood:
//timeBetweenMessages is the minimum time that must elapse between the messages of the same contact.
function antifloodControl(from_jid,from_slug,body,msgID) {
	
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
						return retryToShowMessage(from_jid,from_slug,body,msgID);
  }
	
	//Check if is the first message of this user to be send.
	//var messageQueue = lastMessageTimes[from_slug][1];
	
	if (lastMessageTimes[from_slug][1].length>0){
		if((lastMessageTimes[from_slug][1])[0]==msgID){
			//Message is the first on the queue: Show it and remove from the queue
			lastMessageTimes[from_slug][1].splice(0,1);
		} else {
			//Message is not the first on the queue
			return retryToShowMessage(from_jid,from_slug,body,msgID);
		}
	}
	
	//Message can be send
  lastMessageTimes[from_slug][0] = t;	
  return false;
};


var rootMessageID=1;
function generateMessageID(){
	return (++rootMessageID);
}


function retryToShowMessage(from_jid,from_slug,body,msgID){
	//Enque the message if isn't in the queue
  if (lastMessageTimes[from_slug][1].indexOf(msgID)==-1){
    lastMessageTimes[from_slug][1].push(msgID);
  }
      
  setTimeout(function(){putReceivedMessageOnChatWindow(from_jid,from_slug,body,msgID)}, timeBetweenMessages);
  return true;
}





////////////////////
//Controlflood
////////////////////
var timeBetweenOwnMessages = 500; //mseconds
var lastMessageSentTime=null;

function floodControl() {
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


function initControlFlood(){
	$(".ui-chatbox-input-box")
}


////////////////////
//Bounce chatbox control
////////////////////
var lastBounceTimes = new Array();
var timeBetweenBounces = 5000; //mseconds

function mustBounceBoxForChatWindow(jqueryUIChatbox){
	var from_slug = $($(jqueryUIChatbox.elem.uiChatbox).find(".ui-chatbox-content").children()[0]).attr("id")
	
  var t = (new Date()).getTime();
	
	if(!(from_slug in lastBounceTimes)){
    lastBounceTimes[from_slug] = t;
		return true;
  }
	 
  var lastBounceTime = lastBounceTimes[from_slug];
	
  if (t - lastBounceTime < timeBetweenBounces) {
    return false;
  } else {
		lastBounceTimes[from_slug] = t;
		return true;
	} 
	
}



////////////////////
//Prevent user to send data to the chatbox when he is offline.
////////////////////

function offlineDataSendControl(){
	return ((!disconnectionFlag) && (isStropheConnected()));
}


////////////////////
//Build name from slug
////////////////////

function getNameFromSlug(slug){
	var cname = slug.split("-");
  var name = "";
  for(i=0; i<cname.length; i++){
		 if (i!=0){
		 	name = name + " ";
		 }
     name = name + cname[i][0].toUpperCase() + cname[i].substring(1,cname[i].length);
  }
	return name;
}


////////////////////
//Special slugs management
////////////////////
function isAdminSlug(slug){
	return (slug == '<%=SocialStream::Presence.social_stream_presence_username%>');
}



////////////////////
//Next features...
////////////////////


