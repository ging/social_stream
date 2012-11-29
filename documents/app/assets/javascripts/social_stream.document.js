SocialStream.Document = (function(SS, $, undefined){
	var editCallbacks = [];

	var addEditCallback = function(callback){
		editCallbacks.push(callback);
	};

	var edit = function(options){
		$.each(editCallbacks, function(i, callback){ callback(options); });
	};

  var initTagsForm = function(options) {
    $('#document_tag_list').fcbkcomplete({
        json_url: options.tags.path,
        cache: false,
        filter_case: true,
        filter_hide: true,
        newel: false,
        height: 6
    });
  };

  var initNewActivity = function() {
    $('.wall_input button.new_document').click(function(event){
      event.preventDefault();

      $(this).addClass("selected");

      // build document form
      if ($('.wall_input input[name^=document]').length === 0) {
        $('<label/>', {
          "for": 'document_title',
          text: I18n.t('activerecord.attributes.document.title')
        }).insertBefore($('#post_text'));
        
        $('<textarea/>', {
          name: 'document[description]',
          'class': 'document_description',
          placeholder: I18n.t('document.description.input')
        }).insertAfter($('#post_text'));

        $('.wall_input textarea.document_description').val($('#post_text').val());

        $('#post_text').
          attr('name', 'document[title]').
          attr('placeholder', I18n.t('document.title.input'));

        $('<input>', {
          name: 'document[file]',
          type: 'file'
        }).insertAfter('.wall_input textarea.document_description');
      }

      if ($('.wall_input input[type=file]').is(":visible")) {
        $('.wall_input input[type=file]').trigger('click');
      }
    });

  };

  addEditCallback(initTagsForm);

  SS.Wall.addShowCallback(initNewActivity);

	return {
		edit: edit
  };

})(SocialStream, jQuery);
