//= require social_stream/callback

SocialStream.Link = (function(SS, $) {
  var callback = new SS.Callback();

  var bindOpenCallback = function() {
    $('.link .play_over').click(openCallback);
  };

  var openCallback = function(){
    var url = $(this).attr('data-url'),
        h   = $(this).attr('data-height'),
        w   = $(this).attr('data-width'),
        height = '353';

    if(w>0 && h>0) {
      height=470*h/w;
    }

    $(this).closest('.link').html($('<iframe>').attr('src',url).attr('width','470').attr('height',height));
  };

  callback.register('index', bindOpenCallback);

  callback.register('show', bindOpenCallback);

  return callback.extend({
  });
  
})(SocialStream, jQuery);
