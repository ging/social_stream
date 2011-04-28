$(document).ready(function() {	
	$('input').checkBox();

  $("#new_context_input_block").hide();
  $("#new_level_input_block").hide();
  
  $("#privacy_levels").hide();
  $("#privacy_permissions").hide();
	
	$("#new_context_title").click(function() {
		$("#new_context_title_block").hide();
    $("#new_context_input_block").show();
  });
	
	$("#new_level_title").click(function() {
    $("#new_level_title_block").hide();
    $("#new_level_input_block").show();
  });
	
	$("#cancel_new_context").click(function() {   
    $("#new_context_input_block").hide();
		$("#new_context_title_block").show();
  });
	
	$("#cancel_new_level").click(function() {   
    $("#new_level_input_block").hide();
    $("#new_level_title_block").show();
  });
	
	$("#submit_new_context").click(function() {
    if ($("#new_context_input").val().trim()==""){
      return false;
    }
    createContext();
  });
	
	$("#submit_new_level").click(function() {
    if ($("#new_level_input").val().trim()==""){
      return false;
    }
    createLevel();
  });

});


