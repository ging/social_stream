// initialise plugins
jQuery(function(){
	jQuery('ul.sf-menu').superfish();
});	

$(document).ready(function() {
	  $('#tabvanilla > ul').tabs({ fx: { height: 'toggle', opacity: 'toggle' } });
	  
	});
$(document).ready(function() {
	  $('#tabright> ul').tabs({ fx: { height: 'toggle', opacity: 'toggle' } });
	  
	});

$(document).ready(function() {
	  $('#tabconferences> ul').tabs({ fx: { height: 'toggle', opacity: 'toggle' } });
	  
	});

$(document).ready(function() {
	  $('#tabconference_browse> ul').tabs({ fx: { height: 'toggle', opacity: 'toggle' } });
	  
	});

$(document).ready(function() {
		
	
	$("#info_evento").hide();
	$("#dia_1").hide();
	
	
	
$("#hiddenMiddle").hide();
$("#hiddenRight").hide();


$(".menu > li").click(function(e){
    var a = e.target.id;
    //desactivamos seccion y activamos elemento de menu
    $(".menu li.active").removeClass("active");
    $(".menu #"+a).addClass("active");
    //ocultamos divisiones, mostramos la seleccionada
    $(".content_chat").css("display", "none");
    $("."+a).fadeIn();
});

$('#wideViewMiddle').toggle(
	function(){
		$("#middleContent").hide();
		$('#content').addClass("wideA");
		$('#middle').addClass("wideA");
		$('#right').addClass("wideA");
		$('#chat').addClass("wideA");
		$("#hiddenMiddle").show();
		
	},
	function(){
		$("#rightContent").hide();
		$('#content').addClass("wideB");
		$('#middle').addClass("wideB");
		$('#right').addClass("wideB");
		$('#chat').addClass("wideB");
		$("#hiddenRight").show();
	},
	function(){
		$("#hiddenRight").hide();
		$('#content').removeClass("wideB");
		$('#middle').removeClass("wideB");
		$('#right').removeClass("wideB");
		$('#chat').removeClass("wideB");
		$("#rightContent").show();
		
	},	
	function(){
		$("#hiddenMiddle").hide();
		$('#content').removeClass("wideA");
		$('#middle').removeClass("wideA");
		$('#right').removeClass("wideA");
		$('#chat').removeClass("wideA");
		$("#middleContent").show();
	});
});
