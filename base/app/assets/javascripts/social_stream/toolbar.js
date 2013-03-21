SocialStream.Toolbar = (function(SS, $, undefined){
	var init = function(options){
		$('.toolbar_menu ul li ul').hide();
		$('.toolbar_menu li a').click(function() {
			$(this).next().slideToggle('normal');
		});

		Menu.init(options);
	}

	var Menu = (function(SS, $, undefined){
		var init = function(options){
			//Logo menu for current subject
			//Full Caption Sliding (Hidden to Visible)
			$('.logo_grid.logo_full').hover( function() {
				$(".logo_menu", this).stop().animate({top:'101px'},{queue:false,duration:160});
			}, function() {
				$(".logo_menu", this).stop().animate({top:'1119px'},{queue:false,duration:160});
			});

			if (options != undefined && options['option'] != undefined && options['option'].length) {
				expand(options['option']);
			}
		}

		var expand = function(id) {
			$('#toolbar_menu-' + id).next().show();
		}

		return {
			init: init,
			expand: expand
		}
	})(SS, $)

	return {
		init: init,
		expandMenu: Menu.expand
	}

})(SocialStream, jQuery);
