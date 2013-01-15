SocialStream.RelationCustom = (function(SS, $, undefined){
	// FIXME: DRY!!
	var indexCallbacks = [];

	var addIndexCallback = function(callback){
		indexCallbacks.push(callback);
	};

	var index = function(){
		$.each(indexCallbacks, function(i, callback){ callback(); });
	};

  var getListEl = function() {
    return $('#relation_customs .relation_list');
  };

  var getPermissionsPath = function() {
    return getListEl().attr('data-permissions_path');
  };

  var initList = function() {
    var list = getListEl();

    list.find('.edit_name').hide();
    list.find('.new_relation_custom').hide();
    list.find('.actions').hide();

    list.find('input[type=radio]').click(function() {
      list.find('.actions').hide();
      $(this).closest('.relation_custom').find('.actions').show();
      loadPermissionList(this);
    });

    list.find('.actions .edit').click(function() {
      showEditForm($(this).closest('.relation_custom'));
    });

    list.find('.edit_name .submit').click(function() {
      $(this).closest('.edit_name').find('form').submit();
    });

    list.find('a.new').click(function() {
      $(this).closest('#new_relation').find('.new_relation_custom').toggle('slow');
    });
  };

  var showEditForm = function(el) {
    el.find('label').hide('slow');
    el.find('.actions').hide('slow');

    el.find('.edit_name').show('slow');

    $('html').on('click.social_stream.relation_custom.edit_name', hideEditForms);
  };

  var hideEditForms = function(event) {
    if ($(event.srcElement).closest('.relation_custom').length > 0) {
      return;
    }

    $('.edit_name:visible').each(function() {
      $(this).hide('slow');

      var parent = $(this).closest('.relation_custom');
      parent.find('label').show('slow');
      parent.find('.actions').show('slow');
    });

    $('html').off('click.social_stream.relation_custom.edit_name');
  };

  var loadPermissionList = function(el) {
    var radioInput = $(el);
    var relVal = radioInput.val();
    var formId = '#relation_' + relVal + '_permissions';

    $('#permissions').find('.relation_permissions').hide();
    $(formId).show();

    if (radioInput.attr('data-loaded')) {
      return;
    }

   $.get(
     getPermissionsPath(),
     { relation_id: relVal },
     function(html) {
       $(formId).html(html);
       radioInput.attr('data-loaded', 'true');

       SS.Permission.initForm(formId);
     },
    'html');
  };

  addIndexCallback(initList);

  return {
    index: index
  };

})(SocialStream, jQuery);

/*
function getDomId(id) {
  return id.match(/\d+$/)[0];
}

function selectRelation(radio){
		$("#permissions").html("");
	$('#relation_customs_list div.options').hide();

	$(radio).siblings('div.options').show();

	$.ajax({
		url: "../permissions",
		context: document.body,
		data: { relation_id: getDomId($(radio).attr('id')) },
		dataType: "script"
	});

};

function selectPermission(box){
	var id = getDomId($(box).attr('id'));
	var input = $('input[id="relation_custom_permission_ids_' + id + '"]');
	var label = $('label[for="relation_custom_permission_ids_' + id + '"]');

	if ($(box).is(':checked')) {
		input.attr('checked', 'checked');
		label.parent().show();
	} else {
		input.removeAttr('checked');
		label.parent().hide();
	}
}
*/
