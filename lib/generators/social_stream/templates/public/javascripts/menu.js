function initMenu() {
	$('.menu ul').hide();
	$('.menu li a').click( function() {
		$(this).next().slideToggle('normal');
	}
	);
	//Logo menu for current subject
  //Full Caption Sliding (Hidden to Visible)
  $('.logo_grid.logo_full').hover( function() {
    $(".logo_menu", this).stop().animate({top:'101px'},{queue:false,duration:160});
  }, function() {
    $(".logo_menu", this).stop().animate({top:'1119px'},{queue:false,duration:160});
  });
}

function expandSubMenu(id) {
	$('#' + id + '_menu').next().show();
}

$(document).ready(function() {
	initMenu();
});



