//= require social_stream/callback

SocialStream.Events.Poster = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var init = function(){
    $('.event .poster .update').hide();

    $('.event .poster').hover(
      function(){
      $(this).find(".update").fadeIn("slow");
    },
    function(){
      $(this).find(".update").fadeOut("slow");
    });
  };

  callback.register('show', init);

  return callback.extend({
  });

})(SocialStream, jQuery);
