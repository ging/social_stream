//= require social_stream/callback

SocialStream.SearchHeader = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var nav, mat, timestamp_query, new_query;
  var MIN_TIME_BETWEEN_QUERIES = 1200; // ms
  var WAITING_TIME_FOR_QUICK_SEARCH = 2000; // ms

  var initMat = function() {
    new_query = false;
    nav = $('.search-nav');
    $('input.search-query', nav).focus(focusMat);
    $('input.search-query', nav).on('input', searchQuery);

    timestamp_query = new Date().getTime();
    setInterval(searchIfDirty, WAITING_TIME_FOR_QUICK_SEARCH);

    mat = $('.mat', nav);
    $('div', mat).hide();
  };

  var searchIfDirty = function(){
    if(new_query){
      new_query = false;
      searchQuery();
    }
  };

  var searchQuery = function() {  
    var dif =  new Date().getTime() - timestamp_query;
    if(dif < MIN_TIME_BETWEEN_QUERIES){
      new_query = true;
      return;
    }    

    var input = $('input.search-query', nav);
    var mat = $('.mat', nav);
    var minQuery = input.attr('data-min_query');

    $('div', mat).hide();

    if (input.val().length < minQuery) {
      $('.query_too_short', mat).show();
      return;
    }

    $('.loading', mat).show();

    timestamp_query = new Date().getTime();

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
