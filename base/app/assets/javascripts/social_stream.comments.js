//= require jquery.autosize
//
//= require social_stream.timeline
//= require social_stream.objects

SocialStream.Comments = (function(SS, $, undefined){
  var hideCommentEl = [
    ".avatar",
    "h6",
    "input[type=submit]"
  ];

  var initNew = function(){
    initInputsWithComments();
    newCommentAutoSize();
    newCommentClick();
    newCommentLink();
  };

  var hideNewCommentElements = function(root) {
    if (root === undefined)
      root = ".new_comment";

    $.each(hideCommentEl, function(i, selector) {
      $(root).find(selector).hide();
    });
  };

  var initInputsWithComments = function(){
    // show only the text fields for new comment
    // if there are any comment to the post
    $(".activity .new_comment").each(function(){
      if ($.trim($(this).siblings(".activity .comments").text()) !== ""){
        hideNewCommentElements($(this));
      } else {
        // TODO: find why this is hiding the form of above elements
        $(this).hide();
      }
    });
  };


  var hideNewActivityCommentElements = function(activityId){
    var selector = $('#' + activityId + " .new_comment");

    hideNewCommentElements(selector);
  };

  var newCommentAutoSize = function(){
    $(".new_comment textarea").autosize();
  };

  var newCommentClick = function(){
    $(".new_comment textarea").click(function(){
      hideNewCommentElements();

      var comment= $(this).parents(".new_comment");

      comment.find("input[type=submit]").show();
      comment.find(".avatar").show();

      return false;
    });
  };

  var newCommentLink = function(){
    //javascript for tocomment option
    $(".to_comment").click(function(){
      newCommentEl = $(this).parents(".activity").find(".new_comment");
      newCommentEl.show();
      newCommentEl.find('textarea').click().focus();

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
