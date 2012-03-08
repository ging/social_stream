SocialStream.Calendar = (function(SS, $, undefined){
	var eventElement = function(date) {
		return $('#sidebar_day_' + date.getDate() + '_' + (date.getMonth()+1) + '_' + date.getFullYear())
        }

	var init = function(options){
		var now = new Date();

		eventElement(now).addClass('today');

		var re = new RegExp('sidebar_day_(..?)_(..?)_(..?.?.?)');

		$('#sidebar_calendar td').each(function(index, domEl){
			var m = re.exec(domEl.id);
			if(m == null) return;
			var d = new Date(m[3], (m[2]-1), m[1], 23, 59, 59);
			if(d < now) $(domEl).addClass('past');
			if(m[2] != (now.getMonth()+1) && d > now) $(domEl).addClass('next_month');
		});

		$.ajax({
			dataType: 'json',
			cache: false,
			url: options["eventsPath"],
			data: {
				start: options["start"],
				end: options["end"]
			},
			success: initBusyEvents
		});
	}

	var initBusyEvents = function(events) {
		$.map(events, function(event) {
			var start = new Date(event.start); // This applies TZ
			var end = new Date(event.end);

			for(loopTime=start.getTime(); loopTime <= end.getTime(); loopTime+=86400000) {
				var d = new Date(loopTime);
				var domEl = eventElement(d);

				domEl.addClass("busy");
			}
		})
	}

	return {
		init: init
	}

})(SocialStream, jQuery);
