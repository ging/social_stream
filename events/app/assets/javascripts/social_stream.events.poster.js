SocialStream.Events.Poster = (function(SS, $, undefined){
	var init = function(){
		$('.event_poster_update').hide();

		$('.event_poster').hover(
			function(){
				$(this).find(".event_poster_update").fadeIn("slow");
			        
			},
			function(){
				$(this).find(".event_poster_update").fadeOut("slow");
			});
	}

	SS.Timeline.addSetupCallback(init);

	return {
		init: init
	};

})(SocialStream, jQuery);
