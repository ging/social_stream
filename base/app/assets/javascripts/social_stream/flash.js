SocialStream.Flash = (function(Flashy, undefined) {
  var notice = function(message) {
    Flashy.message('notice', message);
  };

  var error = function(message) {
    if (message === undefined) {
      message = I18n.t('ajax.error');
    }

    Flashy.message('error', message);
  };

  var success = function(message) {
    Flashy.message('success', message);
  };

  var warning = function(message) {
    Flashy.message('warning', message);
  };

  return {
    notice: notice,
    error: error,
    success: success,
    warning: warning
  };
})(Flashy);
