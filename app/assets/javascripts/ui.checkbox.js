/**
 * @author alexander.farkas
 * @version 1.4.1
 */
$(document).ready(function() {

	var baseClasses = /ui-checkbox|ui-radio/;
    $.widget('ui.checkBox', {
		options: {
	        hideInput: true,
			addVisualElement: true,
			addLabel: true,
			_delegated: false
	    },
        _create: function(){
            var that = this, 
				opts = this.options
			;
			
			if(!this.element.is(':radio,:checkbox')){
				if($.nodeName(this.element[0], 'input')){return false;}
				this._addDelegate();
				this.updateContainer();
				return false;
			}
            this.labels = $([]);
			
            this.checkedStatus = false;
			this.disabledStatus = false;
			this.hoverStatus = false;
            
            this.radio = (this.element.is(':radio'));
					
            this.visualElement = $([]);
            if (opts.hideInput) {
				this.element
					.addClass('ui-helper-hidden-accessible')
				;
				if(opts.addVisualElement){
					this.visualElement = $('<span />')
						.addClass(this.radio ? 'ui-radio' : 'ui-checkbox')
					;
					this.element.after(this.visualElement[0]);
				}
            }
			
			if(opts.addLabel){
				this.labels = $('label[for=' + this.element.attr('id') + ']')
					.addClass(this.radio ? 'ui-radio' : 'ui-checkbox')
				;
			}
			if(!opts._delegated){
				this._addEvents();
			}
			this.initialized = true;
            this.reflectUI({type: 'initialReflect'});
			return undefined;
        },
		updateContainer: function(){
			if(!this.element.is(':radio,:checkbox') && !$.nodeName(this.element[0], 'input')){
				$('input', this.element[0])
					.filter(function(){
						return !($.data(this, 'checkBox'));
					})
					.checkBox($.extend({}, this.options, {_delegated: true}))
				;
			}
		},
		_addDelegate: function(){
			var opts 		= this.options,
					
				toggleHover = function(e, that){
					if(!that){return;}
					that.hover = !!(e.type == 'focus' || e.type == 'mouseenter' || e.type == 'focusin' || e.type == 'mouseover');
					that._changeStateClassChain.call(that);
					return undefined;
				}
			;
			
			
			this.element
				.bind('click', function(e){
					if(!$.nodeName(e.target, 'input')){return;}
					var inst = ($.data(e.target) || {}).checkBox;
					if(!inst){return;}
					inst.reflectUI.call(inst, e.target, e);
				})
				.bind('focusin.checkBox focusout.checkBox', function(e){
					if(!$.nodeName(e.target, 'input')){return;}
					var inst = ($.data(e.target) || {}).checkBox;
					toggleHover(e, inst);
				})
			;
			
			if (opts.hideInput){
				this.element
					.bind('usermode', function(e){
						if(!e.enabled){return;}
						$('input', this).each(function(){
		                    var inst = ($.data(this) || {}).checkBox;
							(inst && inst.destroy.call(inst, true));
						});
	                })
				;
            }
			
			if(opts.addVisualElement){
				this.element
					.bind('mouseover.checkBox mouseout.checkBox', function(e){
						if(!$.nodeName(e.target, 'span')){return;}
						var inst = ( $.data($(e.target).prev()[0]) || {} ).checkBox;
						toggleHover(e, inst);
					})
					.bind('click.checkBox', function(e){
						if(!$.nodeName(e.target, 'span') || !baseClasses.test( e.target.className || '' )){return;}
						$(e.target).prev()[0].click();
						return false;
					})
				;
			}
			if(opts.addLabel){
				this.element
					.delegate('label.ui-radio, label.ui-checkbox', 'mouseenter.checkBox mouseleave.checkBox', function(e){
						var inst = ( $.data(document.getElementById( $(this).attr('for') )) || {} ).checkBox;
						toggleHover( e, inst );
					});
			}
			
		},
		_addEvents: function(){
			var that 		= this, 
			
				opts 		= this.options,
					
				toggleHover = function(e){
					if(that.disabledStatus){
						return false;
					}
					that.hover = (e.type == 'focus' || e.type == 'mouseenter');
					that._changeStateClassChain();
					return undefined;
				}
			;
			
			this.element
				.bind('click.checkBox', $.proxy(this, 'reflectUI'))
				.bind('focus.checkBox blur.checkBox', toggleHover)
			;
			if (opts.hideInput){
				this.element
					.bind('usermode', function(e){
	                    (e.enabled &&
	                        that.destroy.call(that, true));
	                })
				;
            }
			if(opts.addVisualElement){
					this.visualElement
						.bind('mouseenter.checkBox mouseleave.checkBox', toggleHover)
						.bind('click.checkBox', function(e){
							that.element[0].click();
							return false;
						})
					;
				}
			if(opts.addLabel){
				this.labels.bind('mouseenter.checkBox mouseleave.checkBox', toggleHover);
			}
		},
		_changeStateClassChain: function(){
			var allElements = this.labels.add(this.visualElement),
				stateClass 	= '',
				baseClass 	= 'ui-'+((this.radio) ? 'radio' : 'checkbox')
			;
				
			if(this.checkedStatus){
				stateClass += '-checked'; 
				allElements.addClass(baseClass+'-checked');
			} else {
				allElements.removeClass(baseClass+'-checked');
			}
			
			if(this.disabledStatus){
				stateClass += '-disabled'; 
				allElements.addClass(baseClass+'-disabled');
			} else {
				allElements.removeClass(baseClass+'-disabled');
			}
			if(this.hover){
				stateClass += '-hover'; 
				allElements.addClass(baseClass+'-hover');
			} else {
				allElements.removeClass(baseClass+'-hover');
			}
			
			baseClass += '-state';
			if(stateClass){
				stateClass = baseClass + stateClass;
			}
			
			function switchStateClass(){
				var classes = this.className.split(' '),
					found = false;
				$.each(classes, function(i, classN){
					if(classN.indexOf(baseClass) === 0){
						found = true;
						classes[i] = stateClass;
						return false;
					}
					return undefined;
				});
				if(!found){
					classes.push(stateClass);
				}
				this.className = classes.join(' ');
			}
			
			this.labels.each(switchStateClass);
			this.visualElement.each(switchStateClass);
		},
        destroy: function(onlyCss){
            this.element.removeClass('ui-helper-hidden-accessible');
						if(this.visualElement){
							this.visualElement.addClass('ui-helper-hidden');
						}
            if (!onlyCss) {
                var o = this.options;
                this.element.unbind('.checkBox');
								if(this.visualElement){
                  this.visualElement.remove();
                }
								if(this.labels){
									this.labels.unbind('.checkBox').removeClass('ui-state-hover ui-state-checked ui-state-disabled');
								}
            }
        },
		
        disable: function(){
            this.element[0].disabled = true;
            this.reflectUI({type: 'manuallyDisabled'});
        },
		
        enable: function(){
            this.element[0].disabled = false;
            this.reflectUI({type: 'manuallyenabled'});
        },
		
        toggle: function(e){
            this.changeCheckStatus((this.element.is(':checked')) ? false : true, e);
        },
		
        changeCheckStatus: function(status, e){
            if(e && e.type == 'click' && this.element[0].disabled){
				return false;
			}
			this.element.attr({'checked': status});
            this.reflectUI(e || {
                type: 'changeCheckStatus'
            });
			return undefined;
        },
		
        propagate: function(n, e, _noGroupReflect){
			if(!e || e.type != 'initialReflect'){
				if (this.radio && !_noGroupReflect) {
					//dynamic
	                $(document.getElementsByName(this.element.attr('name')))
						.checkBox('reflectUI', e, true);
	            }
	            return this._trigger(n, e, {
	                options: this.options,
	                checked: this.checkedStatus,
	                labels: this.labels,
					disabled: this.disabledStatus
	            });
			}
			return undefined;
        },
		
      reflectUI: function(e){
      
				var oldChecked 		= this.checkedStatus, 
				oldDisabledStatus 	= this.disabledStatus;
	            					
				this.disabledStatus = this.element.is(':disabled');
				this.checkedStatus = this.element.is(':checked');
				
				if (this.disabledStatus != oldDisabledStatus || this.checkedStatus !== oldChecked) {
	
					//Change status callback
	
					if (this.checkedStatus==true){
						var id = this.element[0].id;
						checkBoxEnable(id);
					} else if (this.checkedStatus==false){
						var id = this.element[0].id;
						checkBoxDisable(id);
					}
	
					this._changeStateClassChain();
					
					(this.disabledStatus != oldDisabledStatus && this.propagate('disabledChange', e));
					
					(this.checkedStatus !== oldChecked && this.propagate('change', e));
				}
            
      }
    });
});
