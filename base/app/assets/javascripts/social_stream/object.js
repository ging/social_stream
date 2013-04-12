//= require social_stream/audience
//= require social_stream/comment

SocialStream.Object = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initRelationSelect = function(options){
    $('select[name*="relation_ids"]').multiselect({
      'buttonClass': 'btn btn-small',
      'buttonText': relationSelectText,
      'onChange': relationChange
    });
  };

  var relationChange = function(option, checked) {
    var opt      = $(option),
        optId    = opt.val(),
        select   = opt.closest('select'),
        div      = opt.closest('.form-privacy'),
        publicId = div.attr('data-public_id'),
        inputs,
        options;

     if (optId === publicId) {
       options = select.find('option[value!="' + publicId + '"]');
       inputs = div.find('input[value!="' + publicId + '"]');
       } else {
       options = select.find('option[value="' + publicId + '"]');
       inputs  = div.find('input[value="' + publicId + '"]');
     }

     options.prop('selected', false);
     inputs.prop('checked', false);
     inputs.closest('li').removeClass('active');

     $('button', div).html(relationSelectText($('option:selected', select)));
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
