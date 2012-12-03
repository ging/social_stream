// require jquery.ba-url
// require ajax.paginate

SocialStream.Contact = (function($, SS, undefined) {
	var indexCallbacks = [];

	var addIndexCallback = function(callback){
		indexCallbacks.push(callback);
	};

	var index = function(){
		$.each(indexCallbacks, function(i, callback){ callback(); });
	};

  var initTabs = function() {
    $('.contacts ul.nav-tabs a').click(function() {
      if ($(this).attr('data-loaded'))
        return;

      $.ajax({
        url: $(this).attr('data-path'),
        data: { d: $(this).attr('href').replace('#', '') },
        dataType: 'script',
        type: 'GET'
      });
    });
  };

  addIndexCallback(initTabs);

  return {
    index: index
  };
})(jQuery, SocialStream);
