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

	var showCallbacks = [];

	var addShowCallback = function(callback){
		showCallbacks.push(callback);
	};

	var show = function(){
		$.each(showCallbacks, function(i, callback){ callback(); });
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

  var initContactButtons = function() {
    $('.edit_contact select[name*="relation_ids"]').multiselect({
      'button': 'btn btn-small',
      'text': relationSelectText
    });
  };

  var relationSelectText = function(options) {
    if (options.length === 0) {
      return I18n.t('contact.new.button.zero');
    }
    else if (options.length > 2) {
      return I18n.t('contact.new.button', { count: options.length });
    } else {
      var selected = '';
      options.each(function() {
        selected += $(this).text() + ', ';
      });

      return selected.substr(0, selected.length - 2);
    }

  };

  addIndexCallback(initTabs);

  // FIXME There is probably a more efficient way to do this..
  $(function() {
    initContactButtons();
  });

  return {
    index: index,
    show: show
  };
})(jQuery, SocialStream);
