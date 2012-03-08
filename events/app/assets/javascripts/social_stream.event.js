SocialStream.Event = (function(SS, $, undefined) {
	var indexCallbacks = [];

	var addIndexCallback = function(callback){
		indexCallbacks.push(callback);
	}

	var index = function(){
		$.each(indexCallbacks, function(i, callback){ callback(); });
	}

	return {
		addIndexCallback: addIndexCallback,
		index: index
	}

})(SocialStream, jQuery);
