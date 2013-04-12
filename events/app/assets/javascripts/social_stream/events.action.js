//= require social_stream/action

SocialStream.Events.Action = (function(SS, $, undefined){
  var animateCalendar = function(action) {
    if (action.activity_object.type != "Event") {
      return;
    }

    if (!action.follow) {
      return;
    }

    var el = SS.Action.followForms(action).closest(".event");
    var eventDate = new Date(el.find("time").attr('datetime'));

    var calEl = SS.Calendar.eventElement(eventDate);

    if (calEl.length === 0) {
      calEl = SS.Calendar.element();
    }

    if (action.follow.following) {
      el.find('.poster').effect("transfer", {to: calEl});
      calEl.addClass("busy");
    } else {
      calEl.effect("transfer", {to: el.find('.poster')});
      calEl.effect("pulsate");
    }
  };

  SS.Action.callbackRegister('update', animateCalendar);

  return {
  };

})(SocialStream, jQuery);
