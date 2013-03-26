//= require select2
//
//= require social_stream/callback

SocialStream.Profile = (function(SS, $, undefined){
  var callback = new SS.Callback();

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

  callback.register('show',
                    initEditButtons,
                    initTagsForm);

  return callback.extend({
  });

})(SocialStream, jQuery);
