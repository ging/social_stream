////////////////////
//Test functions
////////////////////

function log(msg) {
    console.log(msg)
}


////////////////////
//Hash table
////////////////////
var statusMessage = new Array();
statusMessage[''] = "";
statusMessage['chat'] = "";
statusMessage['away'] = "Away";
statusMessage['xa'] = "Away";
statusMessage['dnd'] = "Busy";

////////////////////
//Strophe functions
////////////////////

//Global variables
var userStatus = "chat";
var awayTimerPeriod = 16000;
var timerPeriod = 5000;
var refreshMinTime = 3*timerPeriod;
var awayTime = 300000;
var awayCounter = 0;
var timerCounter = 0;
var connection = null;
var userConnected = false;
var reconnectAttempts = 3;
var awayTimer;
var timer;
var requestContacts=false;
var cyclesToRefresh = (refreshMinTime/timerPeriod);

function onConnect(status) {
	
	//Status.ERROR An error has occurred
	//Status.CONNECTING The connection is currently being made
	//Status.CONNFAIL The connection attempt failed
	//Status.AUTHENTICATING The connection is authenticating
	//Status.AUTHFAIL The authentication attempt failed
	//Status.CONNECTED  The connection has succeeded
	//Status.DISCONNECTED The connection has been terminated
	//Status.DISCONNECTING  The connection is currently being terminated
	//Status.ATTACHED The connection has been attached
	
	log('Strophe onConnect callback call with status ' + status);
	
	if (status == Strophe.Status.ATTACHED){
		log('Strophe connection attached');
		return;
	} 
	
	if (status == Strophe.Status.AUTHENTICATING ){
    log('Strophe connection AUTHENTICATING');
		return;
  }
	
	if (status == Strophe.Status.CONNECTING) {
     log('Strophe is connecting.');
		 return;
  } 
		
		
	clearTimeout(initialTimer);
		
	if (status == Strophe.Status.CONNFAIL) {
   log('Strophe failed to connect.');
   userConnected = false;
   setTimeout ("onReconnect()", 3000);
  } else if (status == Strophe.Status.AUTHFAIL) {
   log('Strophe authentication fail.');
   if ((window.sessionStorage)&&(sessionStorage.getItem("ss_user_pass") != null)){
    sessionStorage.setItem("ss_user_pass",null);
   }
   userConnected = false;
  } else if (status == Strophe.Status.ERROR) {
   log('Strophe error.');
   userConnected = false;
  } else if (status == Strophe.Status.DISCONNECTED) {
   log('Strophe is disconnected.');
   userConnected = false;
	 clearTimeout(awayTimer);
   setTimeout ("onReconnect()", 3000);
  } else if (status == Strophe.Status.CONNECTED) {
   log('Strophe is connected.');
   log('Presenze stanza send for:' + connection.jid);
   connection.addHandler(onMessage, null, 'message', null, null,  null);
	 connection.addHandler(onPresence, null, 'presence', null, null,  null); 
   //addHandler:(callback, namespace to match, stanza name, stanza type, stanza id , stanza from, options)
   sendStatus(userStatus);
   userConnected = true;
   awayTimer = setInterval("awayTimerFunction()", awayTimerPeriod);
	 timer = setInterval("timerFunction()", timerPeriod);
  }
	
	updateChatWindow();
}

function onReconnect(){
	if ((connection != null)&&(!userConnected)) {
		if (reconnectAttempts>0) {
			reconnectAttempts--;
      connectToServer(null);
      setTimeout ("onReconnect()", 9000);
		} else {
			//Notify issue to Rails App Server?
		}
	}
}

function onMessage(msg) {
    var to = msg.getAttribute('to');
    var from = msg.getAttribute('from');
    var type = msg.getAttribute('type');
    var elems = msg.getElementsByTagName('body');

    if (type == "chat" && elems.length > 0) {
	
			var body = elems[0];
			var from_slug = from.split("@")[0];
			var from_name = $("#" + from_slug).attr("name");
			var from_jid = from_slug + "@" + domain;
			
			log(from + ' says: ' + Strophe.getText(body));
		
		  if (typeof ($('div.user_presence[slug=' + from_slug + ']').attr('name')) == 'undefined') {
		    var from_name = from_slug;
		  } else {
		    var from_name = $('div.user_presence[slug=' + from_slug + ']').attr('name');
		  }
			
			if (mustPlaySoundForChatWindow(window[from_slug])){
          playSound("onMessageAudio");
      }
			
			if (createChatBox(from_slug,from_name,from_jid,user_name,user_jid)) {
			} else {
        window[from_slug].chatbox("option", "boxManager").toggleBox(true);
			}
							
			$("#" + from_slug).chatbox("option", "boxManager").addMsg(from_name, Strophe.getText(body));
			rotatePriority(from_slug);
    }

    // we must return true to keep the handler alive.  
    // returning false would remove it after it finishes.
    return true;
}


function onPresence(presence) {
		  from = $(presence).attr('from');
		  slug = from.split("@")[0];
		  if(slug != user_slug){
		    setTimeout("refreshChatWindow()", 2000);
		  }
	return true;
} 


function sendChatMessage(from,to,text){
    var type = "chat";
    var body= $build("body");
    body.t(text);
    var message = $msg({to: to, from: from, type: 'chat'}).cnode(body.tree());
    connection.send(message.tree());	
		log(from + ' says: ' + text + ' to ' + to);    	
		resumeAwayTimerIfAway();
		return true;
}


////////////////////
//Audio functions
////////////////////

//Global audio variables
var onMessageAudio;

var html5_audiotypes=[
  ["mp3","audio/mpeg"],
  //["mp4","audio/mp4"],
  //["ogg","audio/ogg"],
  ["wav","audio/wav"]
]

function initAudio(){
	//Init all audio files
	initSound("onMessageAudio");
}

function initSound(sound){
	
	//Check support for HTML5 audio
  var html5audio=document.createElement('audio')
	
	if (html5audio.canPlayType){ 
    path = 'assets/chat/' + sound;
    window[sound] = new Audio();

    for(i=0; i<html5_audiotypes.length; i++){
      if (window[sound].canPlayType(html5_audiotypes[i][1])) {
        var source= document.createElement('source');
        source.type= html5_audiotypes[i][1];
        source.src= path + '.' + html5_audiotypes[i][0];
        window[sound].addEventListener('ended', endSoundListener);
        window[sound].appendChild(source);
      } 
    }
  } else {
    //Browser doesn't support HTML5 audio
  }
}

function endSoundListener(){ }

function playSound(sound){
	if (window[sound]!=null){
		window[sound].play();
	} else {
		//Fallback option: When browser doesn't support HTML5 audio
		$('body').append('<embed src="/' + sound + '.mp3" autostart="true" hidden="true" loop="false">');
	}
}

function initAndPlaySound(sound){
    initSound(sound);
		playSound(sound);
}



////////////////////
//Chat view jquery
////////////////////

$(document).ready(function () {
		initialTimer = setTimeout("updateChatWindow()", 15000);
		initAudio();
});

function setUserFunctions(){
	
	$("div.user_presence").click(function(event, ui){
	  var guest_name = $(this).attr("name");
	  var guest_slug = $(this).attr("slug");
	  var guest_jid = guest_slug + "@" + domain;
	  
	  if (createChatBox(guest_slug, guest_name, guest_jid, user_name, user_jid)) {
	  } else {
	    window[guest_slug].chatbox("option", "boxManager").toggleBox(true);
	  };
	});
	
	
	//JQuery DropdwanStatus
	
	$(".dropdown dt a").click(function(event) {
	 	event.preventDefault();
    $(".dropdown dd ul").toggle();
  });
          
  $(".dropdown dd ul li a.option").click(function(event) { 
	  event.preventDefault();
		var text = $(this).html();
    $(".dropdown dt a span").html(text);
    userStatus = getSelectedValue("status");
    sendStatus(userStatus);
		$(".dropdown dd ul").hide();
  });
  
       
  function getSelectedValue(id) {
    return $("#" + id).find("dt a span.value").html();
  }
  
  $(document).bind('click', function(e) {
    var $clicked = $(e.target);
    if (! $clicked.parents().hasClass("dropdown")){
      //Click outside the select...
        $(".dropdown dd ul").hide();
    }
  });
}


function awayTimerFunction(){
	  awayCounter++;
	  if (awayCounter > (awayTime/awayTimerPeriod)){
	    userStatus = "away";
			sendStatus(userStatus);
			clearTimeout(awayTimer);
	  } else {
	    userStatus = "chat";
	  }
}

function resumeAwayTimerIfAway(){
	  if (userStatus == "away"){
			awayCounter = 0;
			userStatus = "chat";
			sendStatus(userStatus);
			awayTimer = setInterval("awayTimerFunction()", awayTimerPeriod);
		}
}

function timerFunction(){
    timerCounter++;	
		
    if((timerCounter > cyclesToRefresh)&&(requestContacts)) {
        requestContacts = false;
        updateChatWindow();
	  }
}

function refreshChatWindow(){  
		if(timerCounter > cyclesToRefresh){
			updateChatWindow();
		} else {
			requestContacts = true;
		}
}

function updateChatWindow(){
	timerCounter=0;
	log("updateChatWindow()");
  $.post("/chatWindow", { userConnected: userConnected }, function(data){ 
      $("#chat_partial").html(data);
      if (userConnected) {
        $(".user_presence a[title]").tooltip();
        setUserFunctions();
      }
  });
}

function sendStatus(status){
    if (status in statusMessage){
	    //Send status to the XMPP Server
	    var pres = $pres()
	    .c('status')
	    .t(statusMessage[status]).up() //Status message
	    .c('show')
	    .t(status);
	     connection.send(pres.tree());
    }
}


function mustPlaySoundForChatWindow(chatBox){
	if(userStatus == "dnd"){
		return false;
	}
	
	if (typeof chatBox == 'undefined') {
		return true;
  }
	
	//Enable sounds only for new (or hidden) chatBoxes
	return (chatBox.chatbox("option", "hidden") == true);
}

////////////////////
//Chat functions
////////////////////

var nBox = 0;
var maxBox = 5;
var chatBoxWidth = 230;
var visibleChatBoxes = new Array();
var chatBoxSeparation = chatBoxWidth+12;


function createChatBox(guest_slug,guest_name,guest_jid,user_name,user_jid){
		
		//Create chatbox for new conversations
		//Open chatbox for old conversations
			
		//Box Variable name = guest_slug
    if (typeof window[guest_slug] == 'undefined') {
			
          //Add div with id = guest_slug
          $("#chat_divs").append("<div id=" + guest_slug + " name=" + guest_name + "></div>")
					
					//Add CSS [...]
          
					
					//Offset Management for new box
					boxParams = getBoxParams();
					var offset = boxParams[0];
					var position = boxParams[1];
					
	
          window[guest_slug] = $("#" + guest_slug).chatbox({id: user_name, 
                              user:{key : "value"},
															hidden: false,
															offset: offset, // relative to right edge of the browser window
                              width: chatBoxWidth, // width of the chatbox
                              title : guest_name,
															position: position,
															priority: visibleChatBoxes.length+1,
															boxClosed: function(id) {
                                
																position = $("#" + guest_slug).chatbox("option", "position");
																
																for (i=position+1;i<visibleChatBoxes.length+1;i++){
																	visibleChatBoxes[i-1].chatbox("option", "offset", visibleChatBoxes[i-1].chatbox("option", "offset") - chatBoxSeparation);
																	visibleChatBoxes[i-1].chatbox("option", "position", visibleChatBoxes[i-1].chatbox("option", "position") - 1 );
                                }
																
																visibleChatBoxes.splice(position-1,1);
																$("#" + guest_slug).chatbox("option", "hidden", true);
																nBox--;
															},
															
                              messageSent : function(id, user, msg) {
																  rotatePriority(guest_slug);
                                  $("#" + guest_slug).chatbox("option", "boxManager").addMsg(id, msg);
                                  sendChatMessage(user_jid,guest_jid,msg);
                              }});
															
					visibleChatBoxes[position-1] = window[guest_slug];
					
					
															
		      return true;
					
    } else {
			
			    if (visibleChatBoxes.indexOf(window[guest_slug]) == -1) {
						
						//Offset Management for old box
						boxParams = getBoxParams();
            var offset = boxParams[0];
            var position = boxParams[1];
		
            window[guest_slug].chatbox("option", "offset", offset);
            window[guest_slug].chatbox("option", "position", position);
            visibleChatBoxes[position-1] = window[guest_slug];
					}  
					
					window[guest_slug].chatbox("option", "hidden", false);
			    return false;
		}
		
}

function getBoxParams(){
	
	var boxParams = new Array(2);
	
		if (nBox==maxBox){
			//Select box to replaced
			replaced = visibleChatBoxes[getBoxIndexToReplace()];           
			replaced.chatbox("option", "hidden", true)
			index = visibleChatBoxes.indexOf(replaced);
			boxParams[0] = replaced.chatbox("option", "offset")
			boxParams[1] = replaced.chatbox("option", "position")
		} else {
		  nBox++;
		  boxParams[0] = (nBox-1)*(chatBoxSeparation);
		  boxParams[1] = nBox;
		}
		
		return boxParams
}


function getBoxIndexToReplace(){

	tmp = visibleChatBoxes[0];
	for (i=0;i<visibleChatBoxes.length;i++){
    if (visibleChatBoxes[i].chatbox("option", "priority") > tmp.chatbox("option", "priority")) {
			tmp = visibleChatBoxes[i];
	  }
  }
	
	return visibleChatBoxes.indexOf(tmp);
}

function rotatePriority(guest_slug){
	priority = $("#" + guest_slug).chatbox("option", "priority")
	if(priority>1){		
			for (i=0;i<visibleChatBoxes.length;i++){
        if(visibleChatBoxes[i].chatbox("option", "priority")<priority){
					visibleChatBoxes[i].chatbox("option", "priority",visibleChatBoxes[i].chatbox("option", "priority")+1);
				}
      }		
			$("#" + guest_slug).chatbox("option", "priority", 1);		
	}	
}


