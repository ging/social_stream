function initMenu() {
	$('.menu ul').hide();
	$('.menu li a').click( function() {
		$(this).next().slideToggle('normal');
	}
	);
}

function expandSubMenu(id) {
	$('#' + id + '_menu').next().show();
}

$(document).ready(function() {
	initMenu();
});
