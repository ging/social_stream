/*
* jQuery.fn.maxSize( options / number );
*
* Put maxsize on images
*
* $('.element').maxSize({
*     width: 'maxWidth',
*     height: 'maxHeight'
* });
*
* Version 1.0.0
* www.labs.skengdon.com/maxSize
* www.labs.skengdon.com/maxSize/js/maxSize.min.js
*/
;(function($){$.fn.maxSize=function(options){if(typeof options!=='object'){var options={width:options,height:options}};return this.each(function(){$img=$(this);var F;var FW=0;var FH=0;if(options.width){FW=$img.width()/options.width;F=1;};if(options.height){FH=$img.height()/options.height;F=0;};if(FW&&FH){F=FW/FH;};if((F>=1)&&(FW>=1)){$(this).width(options.width);};if((F<=1)&&(FH>=1)){$(this).height(options.height);};});};})(jQuery);