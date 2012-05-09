//= require social_stream.timeline

SocialStream.Event = (function(SS, $, undefined) {
	var indexCallbacks = [];

	var addIndexCallback = function(callback){
		indexCallbacks.push(callback);
	}

	var index = function(){
		$.each(indexCallbacks, function(i, callback){ callback(); });
	}

	var color = function(){
		SocialStream.Events.current.eventColor;
	}

        var fixDates = function(){
          $(".event").each(function(){
            dateString = $(this).find("time").attr("datetime");

            date = new Date(dateString);

            var dayEl = $(this).find(".event_day");
	    if (dayEl.length) {
		    dayEl.text($.datepicker.formatDate('d', date));
	    }

            var monthEl = $(this).find(".event_month");
	    if (monthEl.length) {
            	monthEl.text($.datepicker.formatDate('M', date));
	    }

            var hourEl = $(this).find(".event_hour");
            if(hourEl.length) {
              var minutes = date.getMinutes();
              if (minutes<10) minutes = "0" + minutes;
              hourEl.text(date.getHours() + ':' + minutes);
            }

          });

        }

	addIndexCallback(fixDates);

        SocialStream.Timeline.addInitCallback(index);

	return {
		addIndexCallback: addIndexCallback,
		color: color,
		index: index
	}

})(SocialStream, jQuery);
