//= require select2
//= require jqcloud-0.1.3
//= require jquery.validate
//= require jquery.ba-url
//
//= require social_stream/callback

SocialStream.Group = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initParticipants = function() {
    SS.Contact.select2("#group__participants");
  };

  var initTags = function() {
    SS.Tag.select2("#group_tag_list");
  };

  var initValidate = function(options){
    $.each(options.validate, function(i, opt){
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
