// initialise plugins
jQuery(function(){
jQuery('ul.sf-menu').superfish();
});

$(document).ready(function() {
$('#tabright> ul').tabs({ fx: { height: 'toggle', opacity: 'toggle' } });
});

