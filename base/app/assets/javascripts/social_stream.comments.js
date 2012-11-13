//= require jquery.autosize
//
//= require social_stream.timeline
//= require social_stream.objects

SocialStream.Comments = (function(SS, $, undefined){
	var hideCommentEl = [
		".comment .avatar",
		".comment h6",
		".comment input[type=submit]"
	];

	var initNew = function(){
		showInputsWithComments();
		hideNewCommentElements();
		newCommentAutoSize();
		newCommentClick();
		newCommentLink();
	};

	var showInputsWithComments = function(){
		// show only the text fields for new comment
		// if there are any comment to the post
		$(".activity .new_comment").each(function(){
			if ($.trim($(this).siblings(".activity .comments").text()) !== ""){
				$(this).find(".input_new_comments").val("");
			} else {
				$(this).hide();
			}
		});
	};

	var hideNewCommentElements = function(){
		$.each(hideCommentEl, function(i, selector) {
			$(selector).hide();
		});

	};

	var hideNewActivityCommentElements = function(activityId){
		jSelector = $('#' + activityId);

		$.each(hideCommentEl, function(i, selector) {
			jSelector.find(selector).hide();
		});

		jSelector.find(".input_new_comments").hide();
	};

	var newCommentAutoSize = function(){
                $(".input_new_comments").autosize();
	};

	var newCommentClick = function(){
		$(".input_new_comments").click(function(){
			$(".activities .submit").hide();
			$(".new_comment").removeClass("new_comment_shown");
			$(".actor_name_new_comment").hide();
			$(".actor_logo_new_comment").hide();

			var comment= $(this).parents(".activity_new_comment");
			comment.find(".activities_comment_btn").show();
			$(this).parents(".new_comment").addClass("new_comment_shown");
			comment.find(".actor_name_new_comment").show();
			comment.find(".actor_logo_new_comment").show();
                        comment.find(".input_new_comments").show();
			return false;
		});
	};

	var newCommentLink = function(){
		//javascript for tocomment option
		$(".to_comment").click(function(){
			$(this).parents(".activity_content").find(".activity_new_comment").show();
			$(this)
			.closest(".activity_content")
			.find(".input_new_comments")
			.click()
			.focus()
			.val("");

		return false;
		});
	};

	SocialStream.Timeline.addInitCallback(initNew);

	SocialStream.Timeline.addCreateCallback(hideNewActivityCommentElements);
	SocialStream.Timeline.addCreateCallback(newCommentAutoSize);
	SocialStream.Timeline.addCreateCallback(newCommentClick);
	SocialStream.Timeline.addCreateCallback(newCommentLink);

	SocialStream.Objects.addInitCallback(initNew);

	return {
		initNew: initNew
	};

})(SocialStream, jQuery);
