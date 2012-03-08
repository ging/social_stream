SocialStream.Event = (function(SS, $, undefined) {
	var create = function(start, end, allDay) {
		var title = prompt('Event Title:');
		if (title.length) {
			$.post(SocialStream.Events.current.eventsPath,
			       {
					event: {
						title: title,
						start_at: start.toString(),
						end_at: end.toString(),
						all_day: allDay,
						_contact_id: SocialStream.Events.current.contactId
						}
				},
				undefined,
				"script");
		}
	}

	return {
		create: create
	}

})(SocialStream, jQuery);
