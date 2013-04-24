//= require social_stream/wall

SocialStream.Documents.Wall = (function(SS, $, undefined) {
  var initWall = function() {
    $('<label/>', {
      "for": 'new_document_title',
      style: 'display: none;',
      text: I18n.t('activerecord.attributes.document.title')
    }).insertBefore($('#post_text'));

    $('<textarea/>', {
      name: 'document[description]',
      id: 'new_document_description',
      'class': 'document_description',
      style: 'display: none;',
      placeholder: I18n.t('document.description.input')
    }).insertAfter($('#post_text'));

    $('.wall_input form').
      attr('enctype', 'multipart/form-data'); // this is ignored if done after creating the file input

    $('<input>', {
      name: 'document[file]',
      type: 'file',
      style: 'visibility: hidden; position: absolute'
    }).insertAfter('.wall_input textarea.document_description');

    $('.wall_input button.new_document').click(function(event){
      event.preventDefault();

      $('label[for="new_document_title"]').show();

      $('#post_text').
        attr('name', 'document[title]').
        attr('placeholder', I18n.t('document.title.input'));

      $('#new_document_description').show().val($('#post_text').val());

      SocialStream.Wall.changeAction($(this).attr('data-path'));

      SocialStream.Wall.changeOwner('document');
      SocialStream.Wall.changeRelationSelect('document');

      $('.wall_input input[type=file]').trigger('click');
    });

    $('.wall_input input[type=file]').change(function(){
      $("#post_text").val($(this).val().replace(/C:\\fakepath\\/i, ''));
    });
  };

  SS.Wall.callbackRegister('show', initWall);
})(SocialStream, jQuery);
