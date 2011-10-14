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
