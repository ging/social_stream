SocialStream.Document = (function(SS, $, undefined){
	var editCallbacks = [];

	var addEditCallback = function(callback){
		editCallbacks.push(callback);
	};

	var edit = function(options){
		$.each(editCallbacks, function(i, callback){ callback(options); });
	};

  var initTagsForm = function(options) {
    $('#document_tag_list').fcbkcomplete({
        json_url: options.tags.path,
        cache: false,
        filter_case: true,
        filter_hide: true,
        newel: false,
        height: 6
    });
  };

  addEditCallback(initTagsForm);

	return {
		edit: edit
  };

})(SocialStream, jQuery);
