//= require social_stream/callback

SocialStream.Follow = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initButtons = function(){
    $(".following-button").mouseenter(function(){
      $(this).hide();
      $(this).siblings(".unfollow-button").show();
    });

    $(".unfollow-button").mouseleave(function(){
      $(this).hide();
      $(this).siblings(".following-button").show();
    });

    $(".unfollow-button").hide();
  }

  callback.register('index', initButtons);

  $(function(){
    SocialStream.Follow.index();
  });

  return callback.extend({
  });
})(SocialStream, jQuery);
