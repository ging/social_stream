SocialStream.Timeline = (function(SS, $, undefined){
	// FIXME: DRY!!
	var initCallbacks = [];
	var createCallbacks = [];

	var addInitCallback = function(callback){
		initCallbacks.push(callback);
	}

	var addCreateCallback = function(callback){
		createCallbacks.push(callback);
	}

	var init = function(){
		$.each(initCallbacks, function(i, callback){ callback(); });
	}

	var create = function(activityId){
		$.each(createCallbacks, function(i, callback){ callback(activityId); });
	}

	var initPrivacyTooltips = function(activityId) {
		var fullId = '.activity_audience';
		var summaryId = '.activity_audience_summary';

		if (activityId != undefined) {
			fullId = '#' + activityId + ' ' + fullId;
			summaryId = '#' + activityId + ' ' + summaryId;
		}

		$(fullId).hide();
		$(summaryId).tipsy({
			html: true,
			hoverable: true,
			title: function(){
				return $(this).siblings('.activity_audience').html();
			}
		});
	};

	var initComments = function(){
		//if there are 4 or more commments we only show the last 2 and a link to show the rest
		$("#wall .activity_comments").each(function(){
			var comments = $(this).children(".subactivity");  	
			//check if there are more than 3 comments
			if (comments.size() > 3){
				$(this).prepend("<div class='hide_show_comments'><a href='#' onclick='SocialStream.Timeline.showAllComments(\""+ 
					$(this).attr('id') +"\"); return false;'>" + I18n.t('comment.view_all') + "(" +
					comments.size() + ")</a></div><div class='space_comments'></div>");
				comments.slice(0,comments.size()-2).hide();
				//hide alto space_comments
				$(this).children(".space_comments").slice(0,comments.size()-2).hide();
			}
		});

	}

	var showAllComments = function(id){
		$("#"+id).children().show();
		//and hide the hide_show_comments
		$("#"+id).children(".hide_show_comments").hide();
	};


	addInitCallback(initPrivacyTooltips);
	addInitCallback(initComments);

	addCreateCallback(initPrivacyTooltips);

	return {
		addInitCallback: addInitCallback,
		init: init,
		addCreateCallback: addCreateCallback,
		create: create,
		initPrivacyTooltips: initPrivacyTooltips,
		showAllComments: showAllComments
	};
}) (SocialStream, jQuery);
