//= require social_stream/audience
//= require social_stream/comment

SocialStream.Object = (function(SS, $, undefined){
  var callback = new SS.Callback();

  callback.register('show', SS.Comment.index);
  callback.register('show', SS.Audience.index);

  return callback.extend({
  });

})(SocialStream, jQuery);
