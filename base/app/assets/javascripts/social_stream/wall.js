//= require jquery.autosize
//
//= require social_stream/callback

SocialStream.Wall = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initRelationSelect = function(options){
    $('.wall_input select[name*="relation_ids"]').multiselect({
      'buttonClass': 'btn btn-small',
      'buttonText': relationSelectText
    });
  };

  var relationSelectText = function(options) {
    var text;

    if (options.length === 0) {
      text = $(".wall_input").attr('data-relation-text');
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
    $('.wall_input [name$="[relation_ids][]"]').attr('name', type + '[relation_ids][]');
  };


  var initInputAutosize = function() {
    $('.wall_input [name="post[text]"]').autosize();
  };

  var resetWallInput = function(){
    $('#post_text').val('');
  };

  callback.register('show',
                    initInputAutosize,
                    initRelationSelect);

  callback.register('new_',
                    resetWallInput);

  return callback.extend({
    changeRelationSelect: changeRelationSelect 
  });
}) (SocialStream, jQuery);
