//= require social_stream/callback

SocialStream.SearchHeader = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initMat = function() {
    var searchNav = $('.search-nav');
    $('input.search-query', searchNav).on('input', searchQuery);
    $('.mat div', searchNav).hide();
  };

  var searchQuery = function() {
    var nav = $('.search-nav');
    var input = $('input.search-query', nav);
    var mat = $('.mat', nav);
    var minQuery = input.attr('data-min_query');

    $('div', mat).hide();

    if (input.val().length < minQuery) {
      $('.query_too_short', mat).show();
      return;
    }

    $('.loading', mat).show();

    $.ajax({
      url: $('.navbar-search').attr('action'),
      data: {
        q: input.val(),
        mode: 'quick'
      },
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        $('.loading', mat).hide();

        if (data.length > 1) {
          $('.results', mat).html(data).show();
        } else {
          $('.no_results', mat).show();
        }
      }
    });
  };

  callback.register('show', initMat);

  return callback.extend({
  });
}) (SocialStream, jQuery);
