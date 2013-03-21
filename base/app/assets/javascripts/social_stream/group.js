//= require select2
//= require jqcloud-0.1.3
//= require jquery.validate
//= require jquery.ba-url

SocialStream.Group = (function(SS, $, undefined){
  var new_Callbacks = [];

  var addNew_Callback = function(callback){
    new_Callbacks.push(callback);
  };

  var new_ = function(options){
    $.each(new_Callbacks, function(i, callback){ callback(options); });
  };

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

  addNew_Callback(initParticipants);
  addNew_Callback(initTags);
  addNew_Callback(initValidate);

  return {
    new_: new_
  };
})(SocialStream, jQuery);
