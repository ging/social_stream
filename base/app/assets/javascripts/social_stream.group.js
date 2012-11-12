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

	var initTypeahead = function(options){
		$.each(options.typeahead, function(i, opt){
			$(opt.select).typeahead({
				source: function(query, process){
					var qOpts = {};
					qOpts[opt.queryParam] = query;
					return $.get(opt.path, qOpts, function (data) { return process(data); });
				}
			});
		});
	};

	var initValidate = function(options){
		$.each(options.validate, function(i, opt){
			$(opt.form).validate({errorClass: opt.errorClass});
		});
	};

        addNew_Callback(initTypeahead);
        addNew_Callback(initValidate);

	return {
		new_: new_
	};
})(SocialStream, jQuery);
