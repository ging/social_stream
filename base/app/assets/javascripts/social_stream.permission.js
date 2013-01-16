SocialStream.Permission = (function(SS, $, undefined) {
  var initForm = function(formId) {
    $('.edit_relation_custom', formId).on('change', function() {
      $.rails.handleRemote($(this));
    });
  };

  return {
    initForm: initForm
  };
})(SocialStream, jQuery);
