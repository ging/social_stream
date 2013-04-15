//= require social_stream/callback
SocialStream.Notification = (function(SS, $, undefined) {
  var callback = new SS.Callback();

  var initMarkAsRead = function() {
    $('.mark_as_read').click(markAsRead);
  };

  var markAsRead = function(e) {
    console.dir(e);

    if (confirm(I18n.t('sure'))) {
      $.ajax({
        url: $(e.target).attr('href'),
        type: 'PUT',
        success: function() {
          $('.notification').removeClass('unread');
        },
        error: function() {
          SS.Flash.error();
        }
      });
    }

    return false;
  };

  callback.register('index', initMarkAsRead);

  return callback.extend({
  });
})(SocialStream, jQuery);
