SocialStream.Events.Poster = (function(SS, $, undefined){
	var init = function(){
		$('.event .poster .update').hide();

		$('.event .poster').hover(
			function(){
				$(this).find(".update").fadeIn("slow");
			},
			function(){
				$(this).find(".update").fadeOut("slow");
			});
	};

	SS.Timeline.addInitCallback(init);
	SS.Event.addIndexCallback(init);

	return {
		init: init
	};

})(SocialStream, jQuery);
