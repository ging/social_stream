//= require jquery.scrollTo.min
//= require jquery.validate
// cleditor requires jquery-browser
// https://groups.google.com/forum/?fromgroups=#!topic/cleditor/5Vn4YDaQx08
//= require jquery.browser
//= require jquery.cleditor.min

//= require social_stream.pagination

SocialStream.Conversation = (function(SS, $, undefined) {
	var indexCallbacks = [];

	var addIndexCallback = function(callback){
		indexCallbacks.push(callback);
	};

	var index = function(){
		$.each(indexCallbacks, function(i, callback){ callback(); });
	};

  var initPagination = function() {
    SS.Pagination.show();
  };

  addIndexCallback(initPagination);

  return {
    index: index
  };
})(SocialStream, jQuery);
