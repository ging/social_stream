SocialStream.Repository = (function(SS, $, undefined){
  var showCallbacks = [];

  var addShowCallback = function(callback){
    showCallbacks.push(callback);
  };

  var show = function(){
    $.each(showCallbacks, function(i, callback){ callback(); });
  };

  return {
    show: show
  };

}) (SocialStream, jQuery);
