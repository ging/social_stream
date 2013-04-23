//= require social_stream/timeline
//= require social_stream/audio
//= require social_stream/video

SocialStream.Documents.Timeline = (function(SS, $, undefined) {
  var initVideos = function() {
    $(".video-container").hide();

    $(".video .play_over").click(function(){
      var video = $(this).closest(".video");

      video.find(".thumb").hide();
      video.find(".text").hide();
      video.find(".jp-video-play").hide();
      video.find(".video-container").show();
      video.find(".jp-jplayer").jPlayer("play", 0);
    });
  };

  SocialStream.Timeline.callbackRegister('show',
                                         SocialStream.Audio.show,
                                         SocialStream.Video.show,
                                         initVideos);

  SocialStream.Timeline.callbackRegister('update',
                                         SocialStream.Audio.show,
                                         SocialStream.Video.show,
                                         initVideos);
})(SocialStream, jQuery);
