//= require social_stream/callback

SocialStream.Audience = (function(SS, $, undefined) {
  var callback = new SS.Callback();

  var initPrivacyTooltips = function(activityId) {
    var summaryId = '.audience';
    var fullId = '.audience-tooltip';

    if (activityId !== undefined) {
      fullId = '#' + activityId + ' ' + fullId;
      summaryId = '#' + activityId + ' ' + summaryId;
    }

    $(fullId).hide();
    $(summaryId).tooltip({
      html: true,
      trigger: 'click hover',
      title: function(){
        return $(this).siblings(fullId).html();
      }
    });
  };


  callback.register('index', initPrivacyTooltips);

  return callback.extend({
  });
})(SocialStream, jQuery);
