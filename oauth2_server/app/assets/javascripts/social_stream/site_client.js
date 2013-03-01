SocialStream.SiteClient = (function(SS, $, undefined) {
  var indexCallbacks = [];

  var addIndexCallback = function(callback){
    indexCallbacks.push(callback);
  };

  var index = function(options){
    $.each(indexCallbacks, function(i, callback){ callback(options); });
  };

  var initNewModal = function() {
    $('.new_site_client-modal-link').attr('href', '#new_site_client-modal');
  };

  addIndexCallback(initNewModal);

  return {
    index: index
  };

})(SocialStream, jQuery);
