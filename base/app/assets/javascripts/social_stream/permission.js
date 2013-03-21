SocialStream.Permission = (function(SS, $, undefined) {
  var initForm = function(formId) {
    $('.edit_relation_custom', formId).on('change', function() {
      $('#permissions').find('.loading').show();

      $.rails.handleRemote($(this));

      $(this).find('input').prop('disabled', true);
    });
  };

  var enableForm = function(divId) {
    $(divId).find('input').prop('disabled', false);
  };

  return {
    initForm: initForm,
    enableForm: enableForm
  };
})(SocialStream, jQuery);
