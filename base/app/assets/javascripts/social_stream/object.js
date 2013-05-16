//= require social_stream/audience
//= require social_stream/comment

SocialStream.Object = (function(SS, $, undefined){
  var callback = new SS.Callback(),
      pIcon = '<i class="icon_tool16-private"></i>';


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
    var container = $(".form-privacy"),
        publicId  = container.attr('data-public_id'),
        visibility, icon, text;

    if (options.length === 1 && $(options[0]).val() === publicId) {
      icon = pIcon.replace('private', 'public');
    } else {
      icon = pIcon;
    }

    if (options.length === 0) {
      text = container.attr('data-relation-text');
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

    return icon + ' ' + text + ' <b class="caret"></b>';
  };

  var changeRelationSelect = function(type, selector) {
    $('[name$="[relation_ids][]"]', selector).attr('name', type + '[relation_ids][]');
  };

  var changeOwner = function(type, selector) {
    $('[name$="[owner_id]"]', selector).attr('name', type + '[owner_id]');
  };

  callback.register('show',
                    SS.Comment.index,
                    SS.Audience.index);

  callback.register('new_',
                    initRelationSelect);

  return callback.extend({
    changeOwner: changeOwner,
    changeRelationSelect: changeRelationSelect
  });

})(SocialStream, jQuery);
