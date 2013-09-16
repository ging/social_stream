//= require social_stream/callback

SocialStream.SearchHeader = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var nav, mat;

  var initMat = function() {
    nav = $('.search-nav');
    $('input.search-query', nav).focus(focusMat);
    $('input.search-query', nav).on('input', searchQuery);

    mat = $('.mat', nav);
    $('div', mat).hide();
  };

  var searchQuery = function() {
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

  var focusMat = function() {
    mat.show();

    $('html').on('click.close-search-header', closeMat);
  };

  var closeMat = function(e) {
    eventMat = $(e.target).closest('.quick-search');
    
    if (eventMat.length > 0) {
      return;
    }

    mat.hide();

    $('html').off('click.close-search-header');
  };
  
  callback.register('show', initMat);

  return callback.extend({
  });
}) (SocialStream, jQuery);
