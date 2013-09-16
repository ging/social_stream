//= require jquery.autosize
//
//= require social_stream/callback
SocialStream.Comment = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var elAlwaysHidden = [
    "input[type=submit]"
  ];

  var elSometimesShown = [
    ".avatar",
    "textarea"
  ];

  var elAll = elAlwaysHidden.concat(elSometimesShown);

  var appendNewHtml = function(options) {
    $('#comments_activity_' + options.parentActivityId).append(options.html);
  };

  var hideNewCommentElements = function(root) {
    if (root === undefined)
      root = "div.new_comment";

    $.each(elAlwaysHidden, function(i, selector) {
      var e = $(root).find(selector);
      e.hide();
    });
  };

  var showNewCommentElements = function(root) {
    if (root === undefined)
      root = "div.new_comment";

    $.each(elAll, function(i, selector) {
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
        $.each(elSometimesShown, function(i, selector) {
          newDiv.find(selector).hide();
        });
      }
    });
  };

  var hideNewActivityCommentElements = function(options){
    var newDiv = $('#comments_activity_' + options.parentActivityId).siblings('div.new_comment');

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

  var squeeze = function(){
    //if there are 4 or more commments we only show the last 2 and a link to show the rest
    $(".comments").each(function(){
      var comments = $(this).children(".child"),
          showDiv;

      //check if there are more than 3 comments
      if (comments.size() > 3){
        showDiv = $(this).find('.hidden_comments');

        if (showDiv.length) {
          showDiv.find('a').html(I18n.t('comment.view_all', { count: comments.size() }));
          showDiv.show();
          
        } else {
          $(this).prepend("<div class='hidden_comments'><a href='#' onclick='SocialStream.Comment.showAll(\"" + 
                          $(this).attr('id') +"\"); return false;'>" + I18n.t('comment.view_all', { count: comments.size() }) + "</a></div>");
        }

        comments.slice(0, comments.size() - 2).hide();
      }
    });
  };

  var showAll = function(id){
    $("#"+id).children().show('show');
    //and hide the hide_show_comments
    $("#"+id).children(".hidden_comments").hide();
  };

  var scrollToActivity = function(){
    var activity_hash = window.location.hash.match(/^.*activity_(\d+).*$/);

    if (activity_hash && activity_hash > 0){
      $.scrollTo('#activity_' + activity_hash[1] ,1500,{axis:'y'});
    }
  };

  callback.register('index',
                    initNewElements,
                    newCommentAutoSize,
                    newCommentClick,
                    newCommentLink,
                    scrollToActivity,
                    squeeze);

  callback.register('create',
                    appendNewHtml,
                    hideNewActivityCommentElements,
                    newCommentAutoSize,
                    newCommentClick,
                    newCommentLink);

  return callback.extend({
    showAll: showAll
  });

})(SocialStream, jQuery);
