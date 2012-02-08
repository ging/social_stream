SocialStream.Timeline = (function(SS, $, undefined){
	var setupCallbacks = [];

	var addSetupCallback = function(callback){
		setupCallbacks.push(callback);
	}

	var setup = function(){
		$.each(setupCallbacks, function(i, callback){ callback(); });
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

	addSetupCallback(setPrivacyTooltips);

	return {
		addSetupCallback: addSetupCallback,
		setup: setup,
                newActivity: newActivity
	};
}) (SocialStream, jQuery);
