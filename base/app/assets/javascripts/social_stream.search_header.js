SocialStream.SearchHeader = (function(SS, $, undefined){
  var showCallbacks = [];

  var addShowCallback = function(callback){
    showCallbacks.push(callback);
  };

  var show = function(){
    $.each(showCallbacks, function(i, callback){ callback(); });
  };

  var initMat = function() {
    var searchNav = $('.search-nav');
    $('input.search-query', searchNav).on('input', searchQuery);
    $('.loading', searchNav).hide();
  };

  var searchQuery = function() {
    var searchNav = $('.search-nav');
    $('.loading', searchNav).show();

    $.ajax({
      url: $('.navbar-search').attr('action'),
      data: {
        q: $('.navbar-search .search-query').val(),
        mode: 'quick'
      },
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        $('.search-nav .results').html(data);
        $('.loading', searchNav).hide();
      }
    });
  };

  addShowCallback(initMat);

  return {
    show: show
  };
}) (SocialStream, jQuery);
