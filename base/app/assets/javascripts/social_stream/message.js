//= require select2
// cleditor requires jquery.browser
// https://groups.google.com/forum/?fromgroups=#!topic/cleditor/5Vn4YDaQx08
//= require jquery.browser
//= require jquery.cleditor.min
//= require jquery.ae.image.resize
//
//= require social_stream/callback

SocialStream.Message = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initCleditor = function() {
    $('#body').cleditor({
      width: "100%",
      controls: "<%= SocialStream.cleditor_controls %>"
    });
  };

  var initRecipients = function() {
    SocialStream.Contact.select2('#_recipients');
  };

  callback.register('new_',
                    initCleditor,
                    initRecipients);

  return callback.extend({
  });
})(SocialStream, jQuery);
