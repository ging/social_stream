////////////////////
//WINDOW MANAGER MODULE
////////////////////

PRESENCE.WINDOW = (function(P,$,undefined){

  var init = function(){ }
	
	////////////////////
	//ChatBoxes Creation
	////////////////////
	var nBox = 0;
	var maxBox = 5;
	var chatBoxWidth = 230;
	var chatBoxHeight = 180;
	var videoBoxHeight = 145;
	var visibleChatBoxes = new Array();
	var offsetForFlowBox = 0;
	var chatBoxSeparation = chatBoxWidth+12;
	
	
	//Create chatbox for new conversations
	//Open chatbox for old conversations
	var createChatBox = function(guest_slug,isGroup){
	
	    var guest_name = PRESENCE.XMPPClient.getNameFromSlug(guest_slug)
	    
	    if(isGroup){
	      var chatBoxTitle = I18n.t("chat.muc.group", {group: guest_name})
	    } else {
	      var chatBoxTitle = guest_name;
	    }
	
	    //Box Variable name = getChatVariableFromSlug(guest_slug)
	    if (typeof window[getChatVariableFromSlug(guest_slug)] == 'undefined') {
	      
	          //Add div with id = guest_slug
	          $("#chat_divs").append("<div id=" + guest_slug + " name=" + guest_name + " class=chatbox ></div>")
	          
	          //Offset Management for new box
	          boxParams = getBoxParams();
	          var offset = boxParams[0];
	          var position = boxParams[1];
	          
	          window[getChatVariableFromSlug(guest_slug)] = $("#" + guest_slug).chatbox({id: user_name, 
	                              user:{key : "value"},
	                              hidden: false,
	                              offset: offset, // relative to right edge of the browser window
	                              width: chatBoxWidth, // width of the chatbox
	                              height: chatBoxHeight, // height of the chatbox
	                              video: 0, //height of the videoBox
	                              title : chatBoxTitle,
	                              position: position,
	                              priority: visibleChatBoxes.length+1,
	                              groupBox: isGroup,
	                              boxClosed: function(id) {
	                                PRESENCE.WINDOW.closeChatBox(guest_slug)
	                              },
	                              
	                              messageSent: function(id, user, msg){
	                                PRESENCE.XMPPClient.sendChatMessage(guest_slug, msg)
	                              }});
	                              
	          visibleChatBoxes[position-1] = window[getChatVariableFromSlug(guest_slug)];
	                              
	          return true;
	          
	    } else {
	      
	          if (visibleChatBoxes.indexOf(window[getChatVariableFromSlug(guest_slug)]) == -1) {
	            
	            //Offset Management for old box
	            boxParams = getBoxParams();
	            var offset = boxParams[0];
	            var position = boxParams[1];
	    
	            window[getChatVariableFromSlug(guest_slug)].chatbox("option", "offset", offset);
	            window[getChatVariableFromSlug(guest_slug)].chatbox("option", "position", position);
	            visibleChatBoxes[position-1] = window[getChatVariableFromSlug(guest_slug)];
	          }  
	          
	          window[getChatVariableFromSlug(guest_slug)].chatbox("option", "hidden", false);
	          window[getChatVariableFromSlug(guest_slug)].parent().toggle(true)
	          return false;
	    } 
	}
	
	var getBoxParams = function(){
	  
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
	      
	      if((nBox!=1)&&(mainChatBox!=null)){
	        boxParams[0] = boxParams[0] - offsetForFlowBox;
	      }
	      
	      boxParams[1] = nBox;
	    }
	    
	    return boxParams
	}
	
	var closeChatBox = function(guest_slug){
	  var position = getChatBoxForSlug(guest_slug).chatbox("option", "position");
	                                
	  for (i=position+1;i<visibleChatBoxes.length+1;i++){
	    visibleChatBoxes[i-1].chatbox("option", "offset", visibleChatBoxes[i-1].chatbox("option", "offset") - chatBoxSeparation);
	    visibleChatBoxes[i-1].chatbox("option", "position", visibleChatBoxes[i-1].chatbox("option", "position") - 1 );
	  }
	  
	  visibleChatBoxes.splice(position-1,1);
	  $("#" + guest_slug).chatbox("option", "hidden", true);
	  nBox--;
	  
	  if(isSlugGroup(guest_slug)){
	    PRESENCE.XMPPClient.leaveRoom(guest_slug)
	  }
	  
	}
	
	
	////////////////
	//Create Buddy chatBox
	////////////////
	var createBuddyChatBox = function(guest_slug){
	  return createChatBox(guest_slug,false);
	}
	
	
	///////////////////////////
	// Create Group Chat Box
	///////////////////////////
	
	var createGroupChatBox = function(group_slug,open){
	
	  //createChatBox(guest_slug,isGroup)
	  if (createChatBox(group_slug,true)){
	    
	    var groupChatBox = getChatBoxForSlug(group_slug);
	    
	    //Modify default box
	    
	    //Delete games Tick
	    $(getChatBoxButtonForSlug(group_slug,"games")).remove()
	    
	    //Delete video Tick
	    $(getChatBoxButtonForSlug(group_slug,"video")).remove();
	    
	    //Delete video div
	    $(groupChatBox.parent()).find(".ui-videobox").remove();
	    
	    //Minimize
	    groupChatBox.parent().toggle(open);
	    
	    //Initial notifications
	    PRESENCE.NOTIFICATIONS.initialNotificationInGroup(group_slug,I18n.t('chat.muc.joining'))
	    
	    return true;
	  } else {
	    return false;
	  }
	}
	
	
	///////////////////////////
	// Create Main Chat Box
	///////////////////////////
	
	var mainChatBox;
	var connectionBoxesForFile=5;
	var maxConnectionChatBoxesFilesWithoutOverflow = 11;
	var mainChatBoxWidth=150;
	var mainChatBoxaddonsHeight=50;
	var heightForConnectionBoxFile=30;
	var mainChatBoxHeightWhileSearchContacts=260;
	var mainChatBoxMinHeight=136;
	var mainChatBoxMaxHeight= mainChatBoxaddonsHeight + heightForConnectionBoxFile*maxConnectionChatBoxesFilesWithoutOverflow;
	var chatSlugId="SocialStream_MainChat";
	var mainChatBoxParams = [mainChatBoxaddonsHeight,mainChatBoxHeightWhileSearchContacts];
	
	var createMainChatBox = function(){
	  if (mainChatBox==null){
	    //createChatBox(guest_slug,isGroup)
	    createChatBox(chatSlugId,false)
	    mainChatBox = window[getChatVariableFromSlug(chatSlugId)]
	    
	    //Modify default box
	    
	    //Delete closeTick, video Tick and games tick
	    $(mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").find(".ui-icon-closethick").remove();
	    $(mainChatBox.parent().parent()).find(".ui-videobox-icon").remove();
	    $(mainChatBox.parent().parent()).find(".chat-gamesthick").remove();
	    
	    //Margin for minusthick
	    (mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").find(".chat-minusthick").parent().css("margin-right","5px")
	    //Delete nofitications div
	    $(mainChatBox.parent()).find(".ui-chatbox-notify").remove();
	    //Delete video div
	    $(mainChatBox.parent()).find(".ui-videobox").remove();
	    //Delete input
	    $(mainChatBox.parent()).find(".ui-chatbox-input").remove();
	    //Background
	    $(mainChatBox).css("background-color",$(mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").css("background-color"));
	    
	    //Set height
	    changeMainChatBoxHeight(getChatBoxHeightRequiredForConnectionBoxes());
	    
	    //Set width
	    window[getChatVariableFromSlug(chatSlugId)].parent().parent().css( "width", mainChatBoxWidth );
	    $(mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").css( "width", mainChatBoxWidth-6 );
	    $(mainChatBox).css( "width", mainChatBoxWidth-6 );
	    
	    
	    //Adjust window offset
	    offsetForFlowBox = 235-mainChatBoxWidth;
	    
	    //CSS Adjusts
	    $("#chat_partial").css("margin-top",-3)
	    $("#chat_partial").css("margin-left",-3)
	    $(".dropdown dd ul").css("min-width",147) 
	    $(mainChatBox).css('overflow-x','hidden')
	    $(mainChatBox).css('overflow-y','hidden')
	    
	    //Minimize
	    mainChatBox.parent().toggle(PRESENCE.PERSISTENCE.getRestoreMainChatBoxStatus());
	    
	    //Header title
	    PRESENCE.UIMANAGER.updateConnectedUsersOfMainChatBox();
	  }
	}
	
	var getMainChatBox = function(){
		return mainChatBox;
	}
	
	var getMainchatBoxParams = function(){
		return mainChatBoxParams;
	}
	
	//////////////////////////
	// Main Chat Box functions
	//////////////////////////
	
	var addContentToMainChatBox = function(content){
	  if (mainChatBox != null) {
	    $(mainChatBox.parent()).find("#" + chatSlugId).html(content);
	  }
	}
	
	var modifyChatPartialIfMainBox = function(chatPartial){
	  if (mainChatBox != null) {
	    p = $(chatPartial)
	    $(p).find(".header").remove();
	    $(p).find(".dropdown dd ul").css("min-width",147);
	    return $(p); 
	  }
	  
	  return chatPartial;
	}
	
	var changeMainChatBoxHeaderTitle = function(title){
	  if (mainChatBox != null) {
	    $($(mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").find("span")[0]).html(title);
	  }
	}
	
	var changeMainChatBoxHeight = function(height){
	  if (mainChatBox != null) {
	    
	    if(($("#chat_partial #search_chat_contact_flexselect").is(":focus"))&&(! (focusSearchContactsFlag))){
	      return;
	    } else {
	      focusSearchContactsFlag=false;
	    }
	    
	    if(height > mainChatBoxMaxHeight){
	      //overflow = true;
	      height = mainChatBoxMaxHeight;
	      $(mainChatBox).css('overflow-y','visible');
	      mainChatBox.chatbox("option", "offset","5px")
	      mainChatBox.chatbox("option", "width", mainChatBoxWidth + 5)
	    } else {
	      $(mainChatBox).css('overflow-y','hidden');
	      mainChatBox.chatbox("option", "offset","0px")
	      mainChatBox.chatbox("option", "width",mainChatBoxWidth)
	      height = Math.max(height,mainChatBoxMinHeight)
	    }
	    
	    window[getChatVariableFromSlug(chatSlugId)].css("height", height);
	  }
	}

	var getChatBoxHeightRequiredForConnectionBoxes = function(){
	  if(mainChatBox!=null){
	    var desiredHeight = mainChatBoxaddonsHeight + Math.ceil(PRESENCE.UIMANAGER.getAllConnectedSlugs().length/connectionBoxesForFile) * heightForConnectionBoxFile;
	    return desiredHeight;
	  } else {
	    return null;
	  }
	}
	
	
	////////////////////
	//Box replacement
	////////////////////
	
	var getBoxIndexToReplace = function(){
	
	  tmp = visibleChatBoxes[0];
	  for (i=0;i<visibleChatBoxes.length;i++){
	    if (visibleChatBoxes[i].chatbox("option", "priority") > tmp.chatbox("option", "priority")) {
	      tmp = visibleChatBoxes[i];
	    }
	  }
	  
	  return visibleChatBoxes.indexOf(tmp);
	}
	
	var rotatePriority = function(guest_slug){
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
	
	
	////////////////////
	//Video Window Manager functions
	////////////////////
	
	var getVideoBoxForSlug = function(slug){
	  var videoBox = $("#" + slug).parent().find("div.ui-videobox");
	  if(videoBox.length == 1){
	    return videoBox;
	  } else {
	    return null;
	  }
	}
	
	var getPublisherVideoBoxForSlug = function(slug){
	  var pubDiv = $("#stream_publish_videochat_" + slug);
	  if (pubDiv.length > 0) {
	    return pubDiv
	  } else {
	    return null;
	  }
	}
	
	var setVideoBoxContent = function(slug,embed){
	  var videoBox = getVideoBoxForSlug(slug);
	  if(videoBox!=null){
	    videoBox.html(embed);
	  }
	}
	
	var addVideoBoxContent = function(slug,embed){
	  var videoBox = getVideoBoxForSlug(slug);
	  if(videoBox!=null){
	    videoBox.append(embed);
	  }
	}
	
	var showVideoBox = function(chatBox){
	    chatBox.chatbox("option", "video",videoBoxHeight);
	}
	
	var hideVideoBox = function(chatBox){
	  chatBox.chatbox("option", "video", 0);
	}
	
	//Function called from JQuery UI Plugin
	var toggleVideoBox = function(uiElement){
	  var slug = $(uiElement.element).attr("id");
	  PRESENCE.VIDEOCHAT.clickVideoChatButton(slug);
	}
	
	//Function called from JQuery UI Plugin
	var toggleVideoBoxChange = function(uiElement){
	  var slug = $(uiElement.element).attr("id");
	  PRESENCE.VIDEOCHAT.clickVideoChangeChatButton(slug);
	}
	
	var toggleVideoBoxForSlug = function(slug,force){
	  var aux;
	  var chatBox = getChatBoxForSlug(slug);
	  
	  if(chatBox==null) {
	    return null;
	  }
	  
	  if(typeof force != 'undefined'){
	    aux = force;
	  } else {
	    if (chatBox.chatbox("option", "video")==0){
	      aux=true;
	    } else {
	      aux=false;
	    }
	  }
	  
	  if (aux){
	    //Show
	    showVideoBox(chatBox);
	    return true;
	  } else {
	    //Hide
	    hideVideoBox(chatBox);
	    return false;
	  }
	}
	
	
	/////////
	//Getters
	/////////
	var getChatVariableFromSlug = function(slug){
	  return "Slug_" + slug;
	}
	
	var getSlugFromChatVariable = function(variable){
	  return variable.split("_")[1];
	}
	
	var getVisibleChatBoxes = function(){
	  var tmp = new Array();
	  for(i=0; i<visibleChatBoxes.length; i++){
	    if (visibleChatBoxes[i][0].id!=chatSlugId){
	      tmp.push(visibleChatBoxes[i])
	    }
	  }
	  return tmp
	}

	var getAllChatBoxes = function(){
	  return $(".chatbox").not(document.getElementById(chatSlugId))
	}
	
	var getChatBoxForSlug = function(slug){
	  if (typeof window[getChatVariableFromSlug(slug)] == 'undefined') {
	    return null;
	  } else {
	    return window[getChatVariableFromSlug(slug)];
	  }
	}
	
	var getChatBoxHeaderForSlug = function(slug){
	  var chatBox = getChatBoxForSlug(slug);
	  if(chatBox!=null){
	    return chatBox.parent().parent().find(".ui-chatbox-titlebar")
	  } else {
	    return null;
	  }
	}
	
	var getChatBoxButtonsForSlug = function(slug){
	  var chatBoxHeader = getChatBoxHeaderForSlug(slug);
	  if(chatBoxHeader!=null){
	    return chatBoxHeader.find(".ui-chatbox-icon");
	  } else {
	    return null;
	  }
	}
	
	var getChatBoxButtonForSlug = function(slug,button){
	  var chatBoxButtons = getChatBoxButtonsForSlug(slug);
	  if(chatBoxButtons!=null){
	    switch (button){
	      case "close":
	      return chatBoxButtons[0];
	      break;
	      case "min":
	      return chatBoxButtons[1];
	      break;
	      case "video":
	      return chatBoxButtons[2];
	      break;
	      case "videoChange":
	      return chatBoxButtons[3];
	      case "games":
	      return chatBoxButtons[4];
	      break;
	      default : return null;
	    }
	  } else {
	    return null;
	  }
	}
	
	
	var getAllSlugsWithChatOrVideoBoxes = function(){
	  var slugsWithChatBox = [];
	  var slugsWithVideoBox = [];
	  $.each(getAllChatBoxes(), function(index, value) {
	    if($(value).parent().find(".ui-videobox").is(":visible")){
	      slugsWithVideoBox.push($(value).attr("id"))
	    }
	    slugsWithChatBox.push($(value).attr("id"))
	  });
	  return  [slugsWithChatBox,slugsWithVideoBox];
	}
	
	var getAllSlugsWithChatBoxes = function(){
	  return getAllSlugsWithChatOrVideoBoxes()[0];
	}
	
	var getAllSlugsWithVisibleVideoBoxes = function(){
	  return getAllSlugsWithChatOrVideoBoxes()[1];
	}
	
	var getAllDisconnectedSlugsWithChatBoxes = function(){
	  var slugsWithChatBox = getAllSlugsWithChatBoxes();
	  var slugsConnected = PRESENCE.UIMANAGER.getAllConnectedSlugs();
	  var allDisconnectedSlugsWithChatBox = [];
	  
	  $.each(slugsWithChatBox, function(index, value) {
	    if (slugsConnected.indexOf(value)==-1){
	      allDisconnectedSlugsWithChatBox.push(value);
	    }
	  });
	  return allDisconnectedSlugsWithChatBox;
	}
	
	var isSlugGroup = function(slug){
	  var chatBox = getChatBoxForSlug(slug)
	  if(chatBox!=null){
	    return chatBox.chatbox("option", "groupBox")
	  } else {
	    return false
	  }
	}
	
	
	var getAllSlugsWithVisibleGroupBoxes = function(){
	  var groupBoxes = []
	  $.each(getVisibleChatBoxes(), function(index, value) {
	    if ($(value).chatbox("option", "groupBox")){
	      groupBoxes.push($(value).attr("id"));
	    }
	  });
	  return groupBoxes;
	}
	
	var getChatBoxHeight = function(){
		return chatBoxHeight;
	}
	
	
  return {
    init: init,
		createMainChatBox : createMainChatBox,
		createBuddyChatBox : createBuddyChatBox,
		createGroupChatBox : createGroupChatBox,
		closeChatBox : closeChatBox,
		rotatePriority : rotatePriority,
		addContentToMainChatBox : addContentToMainChatBox,
		modifyChatPartialIfMainBox : modifyChatPartialIfMainBox,
		changeMainChatBoxHeaderTitle : changeMainChatBoxHeaderTitle,
		changeMainChatBoxHeight : changeMainChatBoxHeight,
		getChatBoxHeightRequiredForConnectionBoxes : getChatBoxHeightRequiredForConnectionBoxes,
		getVideoBoxForSlug : getVideoBoxForSlug,
		getPublisherVideoBoxForSlug : getPublisherVideoBoxForSlug,
		setVideoBoxContent : setVideoBoxContent,
		addVideoBoxContent : addVideoBoxContent,
		toggleVideoBox : toggleVideoBox,
		toggleVideoBoxChange : toggleVideoBoxChange,
		toggleVideoBoxForSlug : toggleVideoBoxForSlug,
		getVisibleChatBoxes : getVisibleChatBoxes,
		getAllChatBoxes : getAllChatBoxes,
		getChatBoxForSlug : getChatBoxForSlug,
		getChatBoxHeaderForSlug : getChatBoxHeaderForSlug,
		getChatBoxButtonForSlug : getChatBoxButtonForSlug,
		getAllSlugsWithVisibleVideoBoxes : getAllSlugsWithVisibleVideoBoxes,
		getAllDisconnectedSlugsWithChatBoxes : getAllDisconnectedSlugsWithChatBoxes,
		isSlugGroup : isSlugGroup,
		getAllSlugsWithVisibleGroupBoxes : getAllSlugsWithVisibleGroupBoxes,
		getMainChatBox : getMainChatBox,
		getMainchatBoxParams : getMainchatBoxParams,
		getChatBoxHeight : getChatBoxHeight 
  };

}) (PRESENCE, jQuery);

