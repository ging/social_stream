//= require social_stream/callback
//= require social_stream/flash

SocialStream.SiteClient = (function(SS, $, undefined) {
  var callback = new SS.Callback();

  var initNewModal = function() {
    $('.new_site_client-modal-link').attr('href', '#new_site_client-modal');
  };

  var initRefreshButton = function() {
    $('form.site-client-secret').submit(sendSecretRefresh);
  };

  var sendSecretRefresh = function(e) {
    var form = $(e.target);

    e.preventDefault();

    $.ajax({
      url: form.attr('action'),
      method: form.attr('method'),
      dataType: 'json',
      success: function(data) {
        SS.Flash.success(I18n.t('site.client.oauth.secret.refreshed'));

        $('span.site-client-secret').html(data.secret).effect('highlight', {}, 3000);
      },
      error: function(jqXHR, textStatus) {
        SS.Flash.error(textStatus);
      }
    });
  };

  callback.register('index', initNewModal);

  callback.register('show', initRefreshButton);

  return callback.extend({
  });

})(SocialStream, jQuery);
