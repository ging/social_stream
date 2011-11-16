////////////////////
//Test functions
////////////////////

function log(msg) {
    //console.log(msg)
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
//Next features...
////////////////////


