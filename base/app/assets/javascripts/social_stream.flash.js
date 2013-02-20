SocialStream.Flash = (function(Flashy, undefined) {
  var error = function(message) {
    Flashy.message('error', message);
  };

  return {
    error: error
  };
})(Flashy);
