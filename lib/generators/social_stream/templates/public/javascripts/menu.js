function initMenu() {
$('.menu ul').hide();
$('.menu li a').click(
function() {
$(this).next().slideToggle('normal');
}
);
}
$(document).ready(function() {initMenu();});
