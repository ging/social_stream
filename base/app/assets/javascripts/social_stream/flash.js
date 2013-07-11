SocialStream.Flash = (function(Flashy, undefined) {
  var error = function(message) {
    if (message === undefined) {
      message = I18n.t('ajax.error');
    }

    Flashy.message('error', message);
  };

  var success = function(message) {
    Flashy.message('success', message);
  };

  return {
    error: error,
    success: success
  };
})(Flashy);
