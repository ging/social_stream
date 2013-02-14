SocialStream.Explore = (function(SS, $, undefined){
  var indexCallbacks = [];

  var addIndexCallback = function(callback){
    indexCallbacks.push(callback);
  }

  var index = function(options){
    $.each(indexCallbacks, function(i, callback){ callback(index); });
  }

  var headerPushState = function() {
    $('#explore-header button').on('shown', function(e) {
      window.history.pushState({}, {}, $(this).attr('data-state'));
    });
  };

  addIndexCallback(headerPushState);

  return {
	  index: index
  }

})(SocialStream, jQuery);

