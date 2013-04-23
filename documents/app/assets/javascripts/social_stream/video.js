//= require social_stream/callback

SocialStream.Video = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initJplayer = function(){
    $(".jp-video .jp-jplayer").each(function() {
      var container = $(this).closest('.video-container');

      $(this).jPlayer({
        ready: function () {
          $(this).jPlayer("setMedia", {
            webmv: container.attr("data-url-webm"),
            flv:   container.attr("data-url-flv"),
            mp4:   container.attr("data-url-mp4"),
            poster: container.attr("data-url-poster")
          });
        },
      solution:"flash, html",
      preload: "none",
      supplied: "webmv, flv, mp4",
      swfPath: container.attr('data-url-swfplayer'),
      cssSelectorAncestor: "#" + container.attr("id")
      })
    });
  }

  callback.register('show', initJplayer);

  return callback.extend({
  });

})(SocialStream, jQuery);
