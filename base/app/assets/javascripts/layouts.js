//= require hoverIntent
//= require superfish
//= require jquery.watermarkinput
//
$(function() {
    jQuery('ul.sf-menu').superfish({
        animation: {
            height: 'show'
        }, // fade-in and slide-down animation
        speed: 'fast', // faster animation speed
        autoArrows: false,
        dropShadows: false // disable drop shadows
    });

    $('#tabright> ul').tabs({
        fx: {
             height: 'toggle',
            opacity: 'toggle'
        }
    });
});
