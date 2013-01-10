//= require social_stream.timeline
//= require social_stream.wall

SocialStream.Objects = (function(SS, $, undefined){
	var initCallbacks = [];

	var addInitCallback = function(callback){
		initCallbacks.push(callback);
	}

	var init = function(){
		$.each(initCallbacks, function(i, callback){ callback(); });
	}

	addInitCallback(SocialStream.Timeline.initPrivacyTooltips);

	return {
		addInitCallback: addInitCallback,
		init: init
	}

})(SocialStream, jQuery);
