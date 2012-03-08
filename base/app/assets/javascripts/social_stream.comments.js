//= require jquery.watermark
//
//= require social_stream.timeline
//= require social_stream.objects

SocialStream.Comments = (function(SS, $, undefined){
	var initNew = function(){
		// show only the text fields for new comment
		// if there are any comment to the post
		$(".activity_new_comment").each(function(){
			if ($.trim($(this).siblings(".activity_comments").text()) != ""){
				$(this).show();
			}
		});

		$(".activities_comment_btn").hide();
		$(".actor_name_new_comment").hide();
		$(".actor_logo_new_comment").hide();

		$(".input_new_comments").watermark(I18n.t('comment.input'),"#666");

		$(".input_new_comments")
			.change(function(){autoSize(this);})
			.keydown(function(){autoSize(this);})
			.keyup(function(){autoSize(this);});

		$(".input_new_comments").each(function(){autoSize(this)});

		$(".input_new_comments").click(function(){
			$(".activities_comment_btn").hide();
			$(".new_comment").removeClass("new_comment_shown");
			$(".actor_name_new_comment").hide();
			$(".actor_logo_new_comment").hide();
			var comment= $(this).parents(".activity_new_comment");
			comment.find(".activities_comment_btn").show();
			$(this).parents(".new_comment").addClass("new_comment_shown");
			comment.find(".actor_name_new_comment").show();
			comment.find(".actor_logo_new_comment").show();
			return false;
		});

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
	}

	var autoSize = function(e) {
		// Copy textarea contents; browser will calculate correct height of copy,
		// which will make overall container taller, which will make textarea taller.
		var text = $(e).val().replace(/\n/g, '<br/>');
		$(e).siblings(".copy_new_comment").html(text);
	}  

	SocialStream.Timeline.addInitCallback(initNew);
	SocialStream.Objects.addInitCallback(initNew);

	return {
		initNew: initNew
	};

})(SocialStream, jQuery);
