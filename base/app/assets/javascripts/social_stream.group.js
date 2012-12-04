//= require jqcloud-0.1.3
//= require jquery.validate
//= require jquery.ba-url
//= require ajax.paginate

SocialStream.Group = (function(SS, $, undefined){
	var new_Callbacks = [];

	var addNew_Callback = function(callback){
		new_Callbacks.push(callback);
	};

	var new_ = function(options){
		$.each(new_Callbacks, function(i, callback){ callback(options); });
	};

  var initFcbk = function() {
    var url = $("#group__participants").attr('data-path');

    $("#group__participants").fcbkcomplete({
      json_url: url,
      cache: true,
      filter_hide: true,
      newel: false,
      height: 6
    });

    url = $("#group_tag_list").attr('data-path');

    $("#group_tag_list").fcbkcomplete({
      json_url: url,
      cache: false,
      filter_case: true,
      filter_hide: true,
      newel: false,
      height: 6
    });
  };

	var initValidate = function(options){
		$.each(options.validate, function(i, opt){
			$(opt.form).validate({errorClass: opt.errorClass});
		});
	};

  addNew_Callback(initFcbk);
  addNew_Callback(initValidate);

	return {
		new_: new_
	};
})(SocialStream, jQuery);
