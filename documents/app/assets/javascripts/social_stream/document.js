//= require social_stream/callback

SocialStream.Document = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initTagsForm = function() {
    SS.Tag.select2('input[name$="[tag_list]"]');
  };

  var initPagination = function() {
    SS.Pagination.show();
  };

  var initNewModal = function() {
    $('.new_document-modal-link').attr('href', '#new_document-modal');
  };

  callback.register('index', initPagination);

  callback.register('new_', initNewModal);

  callback.register('edit', initTagsForm);

  return callback.extend({
  });

})(SocialStream, jQuery);
