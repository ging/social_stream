$(document).ready(function() {
	
$(".dropdown dt a").click(function() {
	$(".dropdown dd ul").toggle();
});


$('input.input_select').bind('keypress', function(e) {
  if (e.which == '13') {
       //Case: Intro key 
       return false;
     }
  });
        
$(".dropdown dd ul li a.option").click(function() {
	var text = $(this).html();
});


$(document).bind('click', function(e) {
	var $clicked = $(e.target);
	if (! $clicked.parents().hasClass("dropdown")){
	   $(".dropdown dd ul").hide();
	}
});

});