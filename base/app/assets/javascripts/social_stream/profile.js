//= require select2

SocialStream.Profile = (function(SS, $, undefined){
  var showCallbacks = [];

  var addShowCallback = function(callback){
    showCallbacks.push(callback);
  };

  var show = function(options){
    $.each(showCallbacks, function(i, callback){ callback(options); });
  };

  var initEditButtons = function(options) {
    $("#profile-info .update").filter(function(i, el) {
      return options.section.length === 0 || $(el).closest('section').attr('class').indexOf(options.section) === -1;
    }).hide();

    $("#profile-info .edit_icon a[href=#]").click(function(event){
      event.preventDefault();

      var section = $(this).closest('section')[0];

      $("#profile-info section").each(function(i, el) {
        if (el === section)
          return true;

        $(el).find('.briefing').show();
        $(el).find('.update').hide();
      });

      $(section).find('.briefing').toggle('slow');
      $(section).find('.update').toggle('slow');
    });
  };

  var initTagsForm = function(options){
    SS.Tag.select2("#profile_tag_list");
  };

  addShowCallback(initEditButtons);
  addShowCallback(initTagsForm);

  return {
    show: show
  };

})(SocialStream, jQuery);
