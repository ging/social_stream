//= require social_stream/callback

SocialStream.Repository = (function(SS, $, undefined){
  var callback = new SS.Callback();

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
      },
      error: function(data) {
        $('.repository .loading').hide();
        SS.Flash.error();
      }
    });
  };


  callback.register('show', initFilter);

  return callback.extend({
  });

}) (SocialStream, jQuery);
