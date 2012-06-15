//= require social_stream.action

SocialStream.Events.Action = (function(SS, $, undefined){
	var animateCalendar = function(action) {
		if (action.activity_object.type != "Event") {
			return;
		}

		if (!action.follow) {
			return;
		}

		var fromEl = SS.Action.followForms(action).closest(".event").find("time");
		var fromDate = new Date(fromEl.attr('datetime'));

		var toEl = SS.Calendar.eventElement(fromDate) || SS.Calendar.element;

		if (action.follow.following) {
			fromEl.effect("transfer", {to: toEl}, 1000);
			toEl.addClass("busy");
		} else {
			toEl.effect("pulsate");
		}
	}

	SocialStream.Action.addUpdateCallback(animateCalendar);

	return {
	}

})(SocialStream, jQuery);
