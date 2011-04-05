$(document).ready(function() {
	
$("#relationPermissions").hide();

$(".dropdown dt a").click(function() {
	$(".dropdown dd ul").toggle();
});
        
$(".dropdown dd ul li a.option").click(function() {
	var text = $(this).html();
	$(".dropdown dt a span").html(text);
	$(".dropdown dd ul").hide();
	$('input[name$="tie[relation_name]"]').val(getSelectedValue("relationsSelect"));
});


$('input.input_select').click(function() {
	return false;
});

$(".dropdown dd ul li a.input_link").click(function() {
	var text = $('input.input_select').val();
	setSelectedValue(text);

});
        
function getSelectedValue(id) {
	$("#relationPermissions").hide();
	return $("#" + id).find("dt a span.value").html();
}

function setSelectedValue(text){
	if(validate_value_for_input(text)){
		$('input[name$="tie[relation_name]"]').val(text);
	    $(".dropdown dt a span").html(text);
		$("#relationPermissions").show();
	}
	$(".dropdown dd ul").hide();
}

function validate_value_for_input(value){
	var result = true;
	
	if (value.trim()=="") {
		result = false;
	}
	
	var constantOptions = $(".dropdown dd ul li a.option");
	$.each(constantOptions, function(index, item) { 
		if(item.text==value){
			result = false;
		}
		if(item.text==value.trim()){
			result = false;
		}
	});

	return result;
}

function isConstantOptionSelected(){
	var selected = $(".dropdown dt a span.value").text();
	var constantOptions = $(".dropdown dd ul li a.option");
	var result = false;

	$.each(constantOptions, function(index, item) { 
		if(item.text==selected){
			result = true;
		}
	});

	return result;
}


$(document).bind('click', function(e) {
	var $clicked = $(e.target);
	if (! $clicked.parents().hasClass("dropdown")){
	//If any previous option selected...
		if(!isConstantOptionSelected()){
			var text = $('input.input_select').val();
		    	setSelectedValue(text);
		}else{
			$(".dropdown dd ul").hide();
		}
	}
});


$('input.input_select').bind('keypress', function(e) {

	if (e.which == '13') {
	     //Case: Intro key 
	     setSelectedValue($(this).val());
	     return false;
	   }

	});
	
});