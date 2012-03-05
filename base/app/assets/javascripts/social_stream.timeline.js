SocialStream.Timeline = (function(SS, $, undefined){
	var initCallbacks = [];

	var addInitCallback = function(callback){
		initCallbacks.push(callback);
	}

	var init = function(){
		$.each(initCallbacks, function(i, callback){ callback(); });
	}

	var setPrivacyTooltips = function(activityId) {
		var fullId = '.activity_audience';
		var summaryId = '.activity_audience_summary';

		if (activityId != undefined) {
			fullId = '#' + activityId + ' ' + fullId;
			summaryId = '#' + activityId + ' ' + summaryId;
		}

		$(fullId).hide();
		$(summaryId).tipsy({
			html: true,
			title: function(){
				return $(this).siblings('.activity_audience').html();
			}
		});
	};

	var newActivity = function(activityId){
		setPrivacyTooltips(activityId);
		SS.Wall.unblockForms();
	}

	addInitCallback(setPrivacyTooltips);

	return {
		addInitCallback: addInitCallback,
		init: init,
                newActivity: newActivity
	};
}) (SocialStream, jQuery);
