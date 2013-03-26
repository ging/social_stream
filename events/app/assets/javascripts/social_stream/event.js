//= require social_stream/callback
//= require social_stream/events.poster

SocialStream.Event = (function(SS, $, undefined) {
  var callback = new SS.Callback();

  var color = function(){
    return SS.Events.current.eventColor;
  };

  var fixDates = function(){
    $(".event").each(function(){
      dateString = $(this).find("time").attr("datetime");

      date = new Date(dateString);

      var dayEl = $(this).find(".event .day");
      if (dayEl.length) {
        dayEl.text($.datepicker.formatDate('d', date));
      }

      var monthEl = $(this).find(".event .month");
      if (monthEl.length) {
        monthEl.text($.datepicker.formatDate('M', date));
      }

      var hourEl = $(this).find(".event .hour");
      if(hourEl.length) {
        var minutes = date.getMinutes();
        if (minutes<10) minutes = "0" + minutes;
        hourEl.text(date.getHours() + ':' + minutes);
      }
    });
  };

  callback.register('index',
                    fixDates,
                    SocialStream.Events.Poster.show);

  return callback.extend({
    color: color,
  });

})(SocialStream, jQuery);
