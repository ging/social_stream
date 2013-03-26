//= require social_stream/callback

SocialStream.Action = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var updateFollow = function(action){
    var follow = action.follow;

    if (!follow) {
      return;
    }

    followForms(action).replaceWith(follow.form);
    followSentences(action).replaceWith(follow.sentence);
  };

  var followForms = function(action) {
    return $('.follow_form-' + action.activity_object.id);
  };

  var followSentences = function(action) {
    return $('.follow_sentence-' + action.activity_object.id);
  };

  callback.register('update', updateFollow);

  return callback.extend({
    followForms: followForms,
    followSentences: followSentences
  });

})(SocialStream, jQuery);
