SocialStream.Events.Poster = (function(SS, $, undefined){
	var init = function(){
		$('.event .poster_update').hide();

		$('.event .poster').hover(
			function(){
				$(this).find(".event .poster_update").fadeIn("slow");
			        
			},
			function(){
				$(this).find(".event .poster_update").fadeOut("slow");
			});
	}

	SS.Timeline.addInitCallback(init);
	SS.Event.addIndexCallback(init);

	return {
		init: init
	};

})(SocialStream, jQuery);
