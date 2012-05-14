////////////////////
//Social Stream Presence: Parser module
////////////////////

PRESENCE.PARSER = (function(P,$,undefined){

	////////////////////
	//Hash table
	////////////////////
	var chatIcons = new Array();
	chatIcons[':)'] = "face-smile.png";
	chatIcons[':('] = "face-sad.png";
	chatIcons['(B)'] = "beer.png";
	chatIcons['(C)'] = "clock.png";
	chatIcons['(P)'] = "present.png";
	chatIcons[':P']= "face-raspberry.png";
	chatIcons[':Z']= "face-tired.png";
	chatIcons['(R)']= "rain.png";
	chatIcons['(S)']= "sun.png";
	chatIcons[';)']= "face-wink.png";

  var init = function(){ }


	///////////////////////////////////////////////////////
	// Parser functions
	// Allow new features in chat msg like links, images, emoticons, ...
	///////////////////////////////////////////////////////
	
	//Patterns
	var html_tag_pattern=/.*\<[^>]+>.*/g
	var simple_word_pattern=/^[aA-zZ0-9]+$/g
	var http_urls_pattern=/(http(s)?:\/\/)([aA-zZ0-9%=_&+?])+([./-][aA-zZ0-9%=_&+?]+)*[/]?/g
	var www_urls_pattern = /(www[.])([aA-zZ0-9%=_&+?])+([./-][aA-zZ0-9%=_&+?]+)*[/]?/g
	var icons_a_pattern=/\([A-Z]\)/g
	var icons_b_pattern=/((:|;)([()A-Z]))/g
	var youtube_video_pattern=/(http(s)?:\/\/)?(((youtu.be\/)([aA-zZ0-9]+))|((www.youtube.com\/watch\?v=)([aA-z0-9Z&=.])+))/g
	
	
	function getParsedContent(content,fromUser){
	  if (fromUser){
	   var chatTextclass = "ownChatText"
	  } else {
	   var chatTextclass = "guestChatText"
	  }
	  return ("<span class=\"" + chatTextclass + "\">" + parseContent(content) +  "</span>");
	}
	
	
	function parseContent(content){
	  
	  if (content.match(html_tag_pattern)!=null){
	    content = content.replace(/>/g, "&gt;");
	    content = content.replace(/</g, "&lt;");
	    return "<pre>" + content + "</pre>"
	  }
	  
	  var words = content.split(" ");
	  for(i=0; i<words.length; i++){
	    words[i] = parseWord(words[i]);
	  }
	
	  return words.join(" "); 
	}
	
	function parseWord(word){ 
	  
	  //Look for empty or simple words
	  if ((word.trim()=="")||(word.match(simple_word_pattern)!=null)){
	    return word
	  }
	
	  //Look for http urls
	  var http_urls = word.match(http_urls_pattern)
	  if (http_urls!=null){
	    var url = http_urls[0]
	    var type = getUrlType(url);
	  
	    switch(type){
	      case "link":
	        var link = buildUrlLink(url,url)
	        var subwords = splitFirst(word,url)
	        return parseWord(subwords[0]) + link + parseWord(subwords[1])
	      case "image":
	        var imageLink = buildImageLink(url);
	        var subwords = splitFirst(word,url)
	        return parseWord(subwords[0]) + imageLink + parseWord(subwords[1])
	      case "video-youtube":
	        var youtubeLink =  buildYoutubeVideoLink(url);
	        var subwords = splitFirst(word,url)
	        return parseWord(subwords[0]) + youtubeLink + parseWord(subwords[1])
	      default:
	        return word
	    }
	  }
	  
	
	  //Look for www urls
	  var www_urls = word.match(www_urls_pattern)
	  if (www_urls!=null){
	    var url = www_urls[0]
	    var type = getUrlType(url);
	
	    switch(type){
	    case "link":
	      var link = buildUrlLink("http://" + url,url)
	      var subwords = splitFirst(word,url)
	      return parseWord(subwords[0]) + link + parseWord(subwords[1])
	    case "image": 
	      var imageLink = buildImageLink("http://" + url);
	      var subwords = splitFirst(word,url)
	      return parseWord(subwords[0]) + imageLink + parseWord(subwords[1])
	    case "video-youtube":
	        var youtubeLink =  buildYoutubeVideoLink("http://" + url);
	        var subwords = splitFirst(word,url)
	        return parseWord(subwords[0]) + youtubeLink + parseWord(subwords[1])
	    default:
	      return word
	    }  
	  }
	
	  //Look for icons: Regex
	  var icons_a = word.match(icons_a_pattern)
	  if(icons_a!=null){
	    for(g=0; g<icons_a.length; g++){
	        word = word.replace(buildRegex(icons_a[g]), buildIconImage(icons_a[g]))
	    }
	  }
	
	  var icons_b = word.match(icons_b_pattern)
	  if(icons_b!=null){
	    for(h=0; h<icons_b.length; h++){
	        word = word.replace(buildRegex(icons_b[h]), buildIconImage(icons_b[h]))
	    }
	  }
	  
	  
	  //No special content detected (maybe emoticons but not special pattern like urls)
	  return word
	}
	
	function splitFirst(word,key){
	    var split=[]  
	    var cut = word.split(key);   
	    split[0]=cut[0]
	    cut.shift()
	    var paste = cut.join(key)
	    split[1]=paste
	    return split
	}
	
	function buildIconImage(icon){
	  if (icon in chatIcons){
	    var image_file = chatIcons[icon]
	    return "<img class=\"chatEmoticon\" src=\"/assets/emoticons/" + image_file + "\"/>";
	  }
	  return icon
	}
	
	function buildUrlLink(url,name){
	  return "<a target=\"_blank\" class=\"chatLink\" href=\"" + url + "\">" + name + "</a>";
	}
	
	function buildImageLink(url){
	  return "<a target=\"_blank\" class=\"chatImageLink\" href=\"" + url + "\">" + "<img class=\"chatImage\" src=\"" + url + "\"/>" + "</a>";
	}
	
	function buildYoutubeVideoLink(url){
	  //Get youtube video id
	  var youtube_video_id=url.split(/v\/|v=|youtu\.be\//)[1].split(/[?&]/)[0];
	  var youtube_api_url = "http://gdata.youtube.com/feeds/api/videos/" + youtube_video_id
	
	  //Get info from the video
	  $.ajax({
	        type: "GET",
	        url: youtube_api_url,
	        cache: false,
	        dataType:'jsonp',
	        success: function(data){
	          var url_name = url;
	          var youtube_video_thumbnail = "";
	          
	          //Video title
	          var video_title = $(data).find("media\\:title")
	          if (video_title.length > 0) {
	           //url_name = url + " (" + $(video_title).text() + ")";
	           url_name = $(video_title).text()
	          }
	          
	          //Thumbnails
	          var thumbnails = $(data).find("media\\:thumbnail")
	          if (thumbnails.length>0){
	            var thumbnail_url = $(thumbnails[0]).attr("url")
	            if (thumbnail_url!=null){
	              youtube_video_thumbnail = "<p><img class=\"chatVideoImage\" src=\"" + thumbnail_url + "\"/></p>";
	            } 
	          }
	          
	           //Replace video link
	           $("a[youtube_id=" + youtube_video_id + "]").html(buildUrlLink(url,url_name)+youtube_video_thumbnail);
	      },
	        error: function(xOptions, textStatus){
	          //Handle errors
	        }
	   });
	
	  return "<a target=\"_blank\" youtube_id=\"" + youtube_video_id + "\" class=\"chatLink\" href=\"" + url + "\">" + url + "</a>";
	}
	
	function buildRegex(word){
	  word = word.replace(")","\\)")
	  word = word.replace("(","\\(")
	  var pattern = "(" + word + ")";
	  pattern = buildPattern(pattern)
	  return (new RegExp(pattern,'g'));
	}
	
	function buildPattern(pattern){
	  //Escape pattern special characters
	  pattern = pattern.replace("+","\\+")
	  pattern = pattern.replace("?","\\?")
	  return pattern
	}
	
	
	function getUrlType(url){
	
	  if (url.match(youtube_video_pattern)!=null){
	    return  "video-youtube"
	  }
	
	  var urlArray = url.split(".");
	  if (urlArray!=null && urlArray.length>0){
	    var extension= urlArray[urlArray.length-1]
	  } else {
	    var extension = null;
	  }
	
	  switch(extension){
	    case "jpg":
	      return "image"
	      break;
	    case "png":
	      return "image"
	      break;
	    case "gif":
	      return "image"
	      break;
	    default:
	      return "link"
	  }
	}
	
	
	///////////////////////////////////////////////////////
	// Parsing user titles
	///////////////////////////////////////////////////////
	
	function getParsedName(name, fromUser){
	  if (fromUser){
	   var chatTextclass = "ownName"
	  } else {
	   var chatTextclass = "guestName"
	  }
	  return ("<span class=\"" + chatTextclass + "\">" + name +  "</span>");
	}


  return {
    init: init,
		getParsedContent : getParsedContent,
		getParsedName : getParsedName
  };

}) (PRESENCE, jQuery);