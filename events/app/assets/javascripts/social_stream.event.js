//= require social_stream.timeline

SocialStream.Event = (function(SS, $, undefined) {
	var indexCallbacks = [];

	var addIndexCallback = function(callback){
		indexCallbacks.push(callback);
	}

	var index = function(){
		$.each(indexCallbacks, function(i, callback){ callback(); });
	}

        var fixDates = function(){
          $(".event").each(function(){
            dateString = $(this).find("time").attr("datetime");

            date = new Date(dateString);

            $(this).find(".event_day").text($.datepicker.formatDate('d', date));
            $(this).find(".event_month").text($.datepicker.formatDate('M', date));

            var hour = $(this).find(".event_hour");
            if(hour && hour.length) {
              var minutes = date.getMinutes();
              if (minutes<10) minutes = "0" + minutes;
              hour.text(date.getHours() + ':' + minutes);
            }

          });

        }

	addIndexCallback(fixDates);

        SocialStream.Timeline.addInitCallback(index);

	return {
		addIndexCallback: addIndexCallback,
		index: index
	}

})(SocialStream, jQuery);
