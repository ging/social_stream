SocialStream.Explore = (function(SS, $, undefined){
  var indexCallbacks = [];

  var addIndexCallback = function(callback){
    indexCallbacks.push(callback);
  };

  var index = function(options){
    $.each(indexCallbacks, function(i, callback){ callback(index); });
  };

  var headerPushState = function() {
    $('#explore-header div').on('shown', function(e) {
      window.history.pushState({}, {}, $(this).attr('data-path'));
    });
  };

  var initTabLoading = function() {
    $('#explore-header div').on('show', function(e) {
      if ($(this).attr('data-loaded'))
        return;

      var btn = $(e.target);

      $.ajax({
        url: $(e.target).attr('data-path'),
        dataType: 'html',
        type: 'GET',
        success: function(data) {
          $(btn.attr('data-target')).html(data);

          btn.attr('data-loaded', 'true');
        }
      });
    });
  };

  addIndexCallback(headerPushState);
  addIndexCallback(initTabLoading);

  return {
    index: index
  };

})(SocialStream, jQuery);

