//= require jquery.watermark
//
//= require social_stream/callback

SocialStream.Search = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initPagination = function() {
    SS.Pagination.show();
  };

  callback.register('show', initPagination);

  return callback.extend({
  });

}) (SocialStream, jQuery);
