////////////////////
//Chat Window Manager functions
////////////////////

var nBox = 0;
var maxBox = 5;
var chatBoxWidth = 230;
var chatBoxHeight = 170;
var videoBoxHeight = 150;
var visibleChatBoxes = new Array();
var offsetForFlowBox = 0;
var chatBoxSeparation = chatBoxWidth+12;


function createChatBox(guest_slug,guest_name,guest_jid,user_name,user_jid){
		
		//Create chatbox for new conversations
		//Open chatbox for old conversations
			
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
                              title : guest_name,
															position: position,
															priority: visibleChatBoxes.length+1,
															boxClosed: function(id) {
                                closeChatBox(guest_slug)
															},
															
                              messageSent : function(id, user, msg) {
																	rotatePriority(guest_slug);
																	var headerMessage = getParsedName(id,true);
                                  $("#" + guest_slug).chatbox("option", "boxManager").addMsg(headerMessage, getParsedContent(msg,true));
                                  sendChatMessage(user_jid,guest_jid,msg);
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
			
			if((nBox!=1)&&(mainChatBox!=null)){
				boxParams[0] = boxParams[0] - offsetForFlowBox;
			}
			
		  boxParams[1] = nBox;
		}
		
		return boxParams
}


function closeChatBox(guest_slug){
	var position = $("#" + guest_slug).chatbox("option", "position");
                                
  for (i=position+1;i<visibleChatBoxes.length+1;i++){
    visibleChatBoxes[i-1].chatbox("option", "offset", visibleChatBoxes[i-1].chatbox("option", "offset") - chatBoxSeparation);
    visibleChatBoxes[i-1].chatbox("option", "position", visibleChatBoxes[i-1].chatbox("option", "position") - 1 );
  }
  
  visibleChatBoxes.splice(position-1,1);
  $("#" + guest_slug).chatbox("option", "hidden", true);
  nBox--;
}


/////////
//Getters
/////////

function getChatVariableFromSlug(slug){
	return "slug_" + slug;
}

function getSlugFromChatVariable(variable){
	return variable.split("_")[1];
}

function getVisibleChatBoxes(){
	for(i=0; i<visibleChatBoxes.length; i++){
		if (visibleChatBoxes[i][0].id==chatSlugId){
      visibleChatBoxes.splice(i,1)
    }
	}
	return visibleChatBoxes
}


function getAllChatBoxes(){
  return $(".chatbox").not(document.getElementById(chatSlugId))
}

function getChatBoxForSlug(slug){
  if (typeof window[getChatVariableFromSlug(slug)] == 'undefined') {
		return null;
  } else {
		return window[getChatVariableFromSlug(slug)];
	}
}


function getAllSlugsWithChatBoxes(){
	var slugsWithChatBox = [];
	$.each(getAllChatBoxes(), function(index, value) {
    slugsWithChatBox.push($(value).attr("id"))
  });
	return  slugsWithChatBox;
}

function getAllDisconnectedSlugsWithChatBoxes(){
  var slugsWithChatBox = getAllSlugsWithChatBoxes();
	var slugsConnected = getAllConnectedSlugs();
	var allDisconnectedSlugsWithChatBox = [];
	
	$.each(slugsWithChatBox, function(index, value) {
		if (slugsConnected.indexOf(value)==-1){
			allDisconnectedSlugsWithChatBox.push(value);
		}
  });
	return allDisconnectedSlugsWithChatBox;
}



////////////////////
//Box replacement
////////////////////

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



////////////////////
//Video Window Manager functions
////////////////////

function getVideoBoxFromSlug(slug){
	return $("#" + slug).parent().find("div.ui-videobox")
}

function showVideoBox(slug,embed){
	var chatBox = window[getChatVariableFromSlug(slug)]
	getVideoBoxFromSlug(slug).html(embed);
  chatBox.chatbox("option", "video",videoBoxHeight);
}


function hideVideoBox(slug){
	  var chatBox = window[getChatVariableFromSlug(slug)]
    chatBox.chatbox("option", "video", 0);
}


//Function called from JQuery UI Plugin
function toogleVideoBox(uiElement){
	  var slug = $(uiElement.element).attr("id");
    toogleVideoBoxForSlug(slug)
}

function toogleVideoBoxForSlug(slug){
	var chatBox = window[getChatVariableFromSlug(slug)]
	if (chatBox.chatbox("option", "video")==0){
		showVideoBox(slug,getVideoEmbedForSlug(slug))
	} else {
		hideVideoBox(slug);
	}
}

function getVideoEmbedForSlug(slug){
	return "<img src=\"http://www.batiburrillo.net/wp-content/uploads/2011/03/Freemake.jpg?cda6c1\" width=\"" + (chatBoxWidth-20) + "\"/>"
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

function createMainChatBox(){
	if (mainChatBox==null){
		
		//createChatBox(guest_slug,guest_name,guest_jid,user_name,user_jid)
		if (createChatBox(chatSlugId,"Chat","Any","Any","Any")){
			mainChatBox = window[getChatVariableFromSlug(chatSlugId)]
			
			//Modify default box
			
			//Delete closeTick and video Tick
			$(mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").find(".ui-icon-closethick").remove();
			$(mainChatBox.parent().parent()).find(".ui-videobox-icon").remove();
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
			
			//Header title
			updateConnectedUsersOfMainChatBox();
		}
	}
}


function addContentToMainChatBox(content){
	if (mainChatBox != null) {
  	$(mainChatBox.parent()).find("#" + chatSlugId).html(content);
  }
}


function modifyChatPartialIfMainBox(chatPartial){
	if (mainChatBox != null) {
		p = $(chatPartial)
		$(p).find(".header").remove();
		$(p).find(".dropdown dd ul").css("min-width",147);
		return $(p); 
  }
	
	return chatPartial;
}

function changeMainChatBoxHeaderTitle(title){
	if (mainChatBox != null) {
  	$($(mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").find("span")[0]).html(title);
  }
}


function changeMainChatBoxHeight(height){
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


function getChatBoxHeightRequiredForConnectionBoxes(){
	if(mainChatBox!=null){
	  var desiredHeight = mainChatBoxaddonsHeight + Math.ceil(getAllConnectedSlugs().length/connectionBoxesForFile) * heightForConnectionBoxFile;
	  return desiredHeight;
	} else {
		return null;
	}
}


