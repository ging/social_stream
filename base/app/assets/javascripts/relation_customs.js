//= require ui.checkbox

var relations;

function checkBoxId(id) {
  return id.match(/\d+$/)[0];
}

function checkBoxType(id) {
  return id.match(/(.*)_\d+$/)[1]
}

function checkBoxValue(id) {
  return $('label[for$=' + id +']').html(); 
}

function checkBoxOrder(id) {
  return parseInt($('label[for$=' + id +']').attr("order"));
}

function checkBoxIdByOrder(order) {
  return $('label[order$=' + order +']').attr("for");
}


function checkBoxEnable(id) {
	$('div[contain$='+id+']').addClass("checked-option");

        switch (checkBoxType(id)) {

	case "relation_custom":
		if ($('#' + id).parents().hasClass('edit_contact')) {
			break;
		};

		$(':checkbox[id^="relation_custom"]:checked:not(#' + id + ')').checkBox('changeCheckStatus', false);
		$('div[contain$='+id+'] div.options').show();

		$.ajax({
			url: "../permissions",
			context: document.body,
			data: { relation_id: checkBoxId(id) },
                        dataType: "script"
		});

                break;

	case "permission":
                $('input[id="relation_custom_permission_ids_' + checkBoxId(id) + '"]').attr('checked', 'checked');
                $('label[for="relation_custom_permission_ids_' + checkBoxId(id) + '"]').parent().show();

                break;

        default:
          alert("Unknown type of checkBox: " + checkBoxType(id));
        }
}

function checkBoxDisable(id) {
	$('div[contain$='+id+']').removeClass("checked-option");

        switch (checkBoxType(id)) {

	case "relation_custom":
       		if ($('#' + id).parents().hasClass('edit_contact')) {
			break;
		};

	        $("#permissions").html("");
		$("#permissions").hide();

		$('div[contain$='+id+'] div.options').hide();

                break;

	case "permission":
                $('input[id="relation_custom_permission_ids_' + checkBoxId(id) + '"]').removeAttr('checked');
                $('label[for="relation_custom_permission_ids_' + checkBoxId(id) + '"]').parent().hide();

                break;
        default:
          alert("Unknown type of checkBox: " + checkBoxType(id));

        }
} 
