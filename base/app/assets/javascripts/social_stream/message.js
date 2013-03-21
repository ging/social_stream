//= require select2
// cleditor requires jquery.browser
// https://groups.google.com/forum/?fromgroups=#!topic/cleditor/5Vn4YDaQx08
//= require jquery.browser
//= require jquery.cleditor.min
//= require jquery.ae.image.resize

SocialStream.Message = (function(SS, $, undefined){
  var new_Callbacks = [];

  var addNew_Callback = function(callback){
    new_Callbacks.push(callback);
  };

  var new_ = function(options){
    $.each(new_Callbacks, function(i, callback){ callback(options); });
  };

  var initCleditor = function() {
    $('#body').cleditor({
      width: "100%",
      controls: "<%= SocialStream.cleditor_controls %>"
    });
  };

  var initRecipients = function() {
    SocialStream.Contact.select2('#_recipients');
  };

  addNew_Callback(initCleditor);
  addNew_Callback(initRecipients);

  return {
    new_: new_
  };
})(SocialStream, jQuery);
