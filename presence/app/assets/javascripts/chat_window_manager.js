////////////////////
//Chat Window Manager functions
////////////////////

var nBox = 0;
var maxBox = 5;
var chatBoxWidth = 230;
var chatBoxHeight = 170;
var videoBoxHeight = 150;
var visibleChatBoxes = new Array();
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
var chatSlugId="SocialStream_MainChat"

function createMainChatBox(){
	if (mainChatBox==null){
		
		//createChatBox(guest_slug,guest_name,guest_jid,user_name,user_jid)
		if (createChatBox(chatSlugId,"Chat","Any","Any","Any")){
			mainChatBox = window[getChatVariableFromSlug(chatSlugId)]
			
			//Modify default box
			
			//Delete closeTick and video Tick
			$(mainChatBox.parent().parent()).find(".ui-chatbox-titlebar").find(".ui-icon-closethick").remove();
			$(mainChatBox.parent().parent()).find(".ui-videobox-icon").remove()
			//Delete nofitications div
			$(mainChatBox.parent()).find(".ui-chatbox-notify").remove();
			//Delete video div
			$(mainChatBox.parent()).find(".ui-videobox").remove();
			//Delete input
			$(mainChatBox.parent()).find(".ui-chatbox-input").remove();
			
			//Set height
			//window[getChatVariableFromSlug(chatSlugId)].css( "width", "160" ) 
			
			//Set width
			
			//Adjust 
			
		}
	}
}

function addContentToMainChatBox(content){
	$(mainChatBox.parent()).find("#" + chatSlugId).html(content);
}
