//= require social_stream.objects

SocialStream.Activity = (function(SS, $, undefined){
	var scrollToActivity = function(){
		var activity_hash = window.location.hash.match(/^.*activity_(\d+).*$/);
		if (activity_hash && activity_hash > 0){
			$.scrollTo('#activity_' + activity_hash[1] ,1500,{axis:'y'});
		}

	}

	SS.Objects.addInitCallback(scrollToActivity);

	return {
	}
})(SocialStream, jQuery);
