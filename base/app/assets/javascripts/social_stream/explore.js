//= require social_stream/callback

SocialStream.Explore = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var headerPushState = function() {
    $('#explore-header div').on('shown', function(e) {
      if ($(this).attr('data-onpop')) {
        $(this).removeAttr('data-onpop');
      } else {
        window.history.pushState({ target: $(this).attr('data-target') }, {}, $(this).attr('data-path'));
      }
    });

    window.onpopstate = function(event) {
      if (event.state && event.state.target) {
        var btn = $('#explore-header div[data-target="' + event.state.target + '"]');
        btn.attr('data-onpop', 'true');
        btn.click();
      }
    };
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

  callback.register('index',
                    headerPushState,
                    initTabLoading);

  return callback.extend({
  });

})(SocialStream, jQuery);

