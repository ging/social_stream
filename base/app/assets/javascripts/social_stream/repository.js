SocialStream.Repository = (function(SS, $, undefined){
  var showCallbacks = [];

  var addShowCallback = function(callback){
    showCallbacks.push(callback);
  };

  var show = function(){
    $.each(showCallbacks, function(i, callback){ callback(); });
  };

  var initFilter = function() {
    $('.repository .loading').hide();
    $("#repository .filter").on('input', filter);
  };

  var filter = function() {
    var path = $(this).attr('data-path');
    var q = $(this).val();

    $('.repository .loading').show();

    $.ajax({
      url: path,
      data: {
        q: q
      },
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        $('.repository .loading').hide();
        $('.repository-list').html(data);
      }
    });
  };


  addShowCallback(initFilter);

  return {
    show: show
  };

}) (SocialStream, jQuery);
