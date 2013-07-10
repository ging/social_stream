//= require select2
//= require jqcloud-0.1.3
//= require jquery.validate
//= require jquery.ba-url
//
//= require social_stream/callback
//= require social_stream/actor

SocialStream.Group = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initParticipants = function(options) {
    SS.Actor.select2(options.form + ' input[name$="[owners]"]');
  };

  var initTags = function(options) {
    SS.Tag.select2(options.form + ' input[name$="[tag_list]"]');
  };

  var initValidate = function(options){
    $.each($(options.form), function(i, opt){
      $(opt.form).validate({errorClass: opt.errorClass});
    });
  };

  callback.register('new_',
                    initParticipants,
                    initTags,
                    initValidate);

  return callback.extend({
  });
})(SocialStream, jQuery);
