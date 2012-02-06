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
    path = '/assets/chat/' + sound;
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


function mustPlaySoundForChatWindow(chatBox){
  //Deny conditions
  if(userStatus == "dnd"){
    return false;
  }
  
  //Accept conditions
  if (!chatFocus){
    return true;
  }
  
  //Default action
  return false
}