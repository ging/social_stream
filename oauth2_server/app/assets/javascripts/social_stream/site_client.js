//= require social_stream/callback

SocialStream.SiteClient = (function(SS, $, undefined) {
  var callback = new SS.Callback();

  var initNewModal = function() {
    $('.new_site_client-modal-link').attr('href', '#new_site_client-modal');
  };

  callback.register('index', initNewModal);

  return callback.extend({
  });

})(SocialStream, jQuery);
