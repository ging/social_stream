//= require social_stream/audience
//= require social_stream/comment

SocialStream.Object = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initRelationSelect = function(options){
    $('select[name*="relation_ids"]').multiselect({
      'buttonClass': 'btn btn-small',
      'buttonText': relationSelectText
    });
  };

  var relationSelectText = function(options) {
    var text;

    if (options.length === 0) {
      text = $(".form-privacy").attr('data-relation-text');
    }
    else if (options.length > 3) {
      text = I18n.t('activity.privacy.relation', { count: options.length });
    } else {
      var selected = '';
      options.each(function() {
        selected += $(this).text() + ', ';
      });

      text = selected.substr(0, selected.length - 2);
    }

    return text + ' <b class="caret"></b>';
  };

  var changeRelationSelect = function(type) {
    $('[name$="[relation_ids][]"]').attr('name', type + '[relation_ids][]');
  };

  callback.register('show',
                    SS.Comment.index,
                    SS.Audience.index);

  callback.register('new_',
                    initRelationSelect);

  return callback.extend({
    changeRelationSelect: changeRelationSelect
  });

})(SocialStream, jQuery);
