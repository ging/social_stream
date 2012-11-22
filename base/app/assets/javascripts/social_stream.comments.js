//= require jquery.autosize
//
//= require social_stream.timeline
//= require social_stream.objects

SocialStream.Comments = (function(SS, $, undefined){
  var newElementsToHide = [
    ".avatar",
    "h6",
    "input[type=submit]"
  ];

  var initNew = function(){
    initNewElements();
    newCommentAutoSize();
    newCommentClick();
    newCommentLink();
  };

  var hideNewCommentElements = function(root) {
    if (root === undefined)
      root = "div.new_comment";

    $.each(newElementsToHide, function(i, selector) {
      var e = $(root).find(selector);
      console.dir(e);
      e.hide();
    });
  };

  var showNewCommentElements = function(root) {
    if (root === undefined)
      root = "div.new_comment";

    $.each(newElementsToHide, function(i, selector) {
      $(root).find(selector).show();
    });
  };


  var initNewElements = function(){
    hideNewCommentElements();

    // show only the text fields for new comment
    // if there are any comment to the post
    $(".root").each(function(){
      var commentsDiv = $(this).find('div.comments');
      var newDiv = $(this).find('div.new_comment');

      if ($.trim(commentsDiv.text()) === ""){
        newDiv.find('textarea').hide();
      }
    });
  };


  var hideNewActivityCommentElements = function(activityId){
    var newDiv = $('#' + activityId).closest('.root').find('div.new_comment');

    newDiv.find("textarea").val('');

    hideNewCommentElements(newDiv);
  };

  var newCommentAutoSize = function(){
    $(".new_comment textarea").autosize();
  };

  var newCommentClick = function(){
    $(".new_comment textarea").click(function(){
      var newDiv = $(this).closest("div.new_comment");

      showNewCommentElements(newDiv);
    });


    $(".new_comment textarea").blur(function(){
      if ($(this).val() === "")
        hideNewCommentElements($(this).closest('div.new_comment'));
    });
  };

  var newCommentLink = function(){
    //javascript for tocomment option
    $(".to_comment").click(function(){
      var newDiv = $(this).closest(".root").find("div.new_comment");

      newDiv.find('textarea').show().click().focus();

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
