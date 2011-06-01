;(function($) {
    /*
    * ui.dropdownchecklist
    *
    * Copyright (c) 2008-2010 Adrian Tosca, Copyright (c) 2010 Ittrium LLC
    * Dual licensed under the MIT (MIT-LICENSE.txt)
    * and GPL (GPL-LICENSE.txt) licenses.
    *
    */
    // The dropdown check list jQuery plugin transforms a regular select html element into a dropdown check list.
    $.widget("ui.dropdownchecklist", {
    	// Some globlals
    	// $.ui.dropdownchecklist.gLastOpened - keeps track of last opened dropdowncheck list so we can close it
    	// $.ui.dropdownchecklist.gIDCounter - simple counter to provide a unique ID as needed
        version: function() {
            alert('DropDownCheckList v1.1');
        },    	
        // Creates the drop container that keeps the items and appends it to the document
        _appendDropContainer: function( controlItem ) {
            var wrapper = $("<div/>");
            // the container is wrapped in a div
            wrapper.addClass("ui-dropdownchecklist ui-dropdownchecklist-dropcontainer-wrapper");
            wrapper.addClass("ui-widget");
            // assign an id
            wrapper.attr("id",controlItem.attr("id") + '-ddw');
            // initially hidden
            wrapper.css({ position: 'absolute', left: "-33000px", top: "-33000px"  });
            
            var container = $("<div/>"); // the actual container
            container.addClass("ui-dropdownchecklist-dropcontainer ui-widget-content");
            container.css("overflow-y", "auto");
            wrapper.append(container);
            
            // insert the dropdown after the master control to try to keep the tab order intact
            // if you just add it to the end, tabbing out of the drop down takes focus off the page
            // @todo 22Sept2010 - check if size calculation is thrown off if the parent of the
            //		selector is hidden.  We may need to add it to the end of the document here, 
            //		calculate the size, and then move it back into proper position???
			//$(document.body).append(wrapper);
            wrapper.insertAfter(controlItem);

            // flag that tells if the drop container is shown or not
            wrapper.isOpen = false;
            return wrapper;
        },
        // Look for browser standard 'open' on a closed selector
		_isDropDownKeyShortcut: function(e,keycode) {
			return e.altKey && ($.ui.keyCode.DOWN == keycode);// Alt + Down Arrow
		},
		// Look for key that will tell us to close the open dropdown
		_isDropDownCloseKey: function(e,keycode) {
			return ($.ui.keyCode.ESCAPE == keycode) || ($.ui.keyCode.ENTER == keycode);
		},
		// Handler to change the active focus based on a keystroke, moving some count of
		// items from the element that has the current focus
		_keyFocusChange: function(target,delta,limitToItems) {
			// Find item with current focus
			var focusables = $(":focusable");
			var index = focusables.index(target);
			if ( index >= 0 ) {
				index += delta;
				if ( limitToItems ) {
					// Bound change to list of input elements
	            	var allCheckboxes = this.dropWrapper.find("input:not([disabled])");
	            	var firstIndex = focusables.index(allCheckboxes.get(0));
	            	var lastIndex = focusables.index(allCheckboxes.get(allCheckboxes.length-1));
	            	if ( index < firstIndex ) {
	            		index = lastIndex;
	            	} else if ( index > lastIndex ) {
	            		index = firstIndex;
	            	}
	            }
				focusables.get(index).focus();
			}
		},
		// Look for navigation, open, close (wired to keyup)
		_handleKeyboard: function(e) {
			var self = this;
			var keyCode = (e.keyCode || e.which);
			if (!self.dropWrapper.isOpen && self._isDropDownKeyShortcut(e, keyCode)) {
				// Key command to open the dropdown
				e.stopImmediatePropagation();
				self._toggleDropContainer(true);
			} else if (self.dropWrapper.isOpen && self._isDropDownCloseKey(e, keyCode)) {
				// Key command to close the dropdown (but we retain focus in the control)
				e.stopImmediatePropagation();
				self._toggleDropContainer(false);
				self.controlSelector.focus();
			} else if (self.dropWrapper.isOpen 
					&& (e.target.type == 'checkbox')
					&& ((keyCode == $.ui.keyCode.DOWN) || (keyCode == $.ui.keyCode.UP)) ) {
				// Up/Down to cycle throught the open items
				e.stopImmediatePropagation();
				self._keyFocusChange(e.target, (keyCode == $.ui.keyCode.DOWN) ? 1 : -1, true);
			} else if (self.dropWrapper.isOpen && (keyCode == $.ui.keyCode.TAB) ) {
				// I wanted to adjust normal 'tab' processing here, but research indicates
				// that TAB key processing is NOT a cancelable event. You have to use a timer
				// hack to pull the focus back to where you want it after browser tab
				// processing completes.  Not going to work for us.
				//e.stopImmediatePropagation();
				//self._keyFocusChange(e.target, (e.shiftKey) ? -1 : 1, true);
           }
		},
		// Look for change of focus
		_handleFocus: function(e,focusIn,forDropdown) {
			var self = this;
			if (forDropdown && !self.dropWrapper.isOpen) {
				// if the focus changes when the control is NOT open, mark it to show where the focus is/is not
				e.stopImmediatePropagation();
				if (focusIn) {
					self.controlSelector.addClass("ui-state-hover");
					if ($.ui.dropdownchecklist.gLastOpened != null) {
						$.ui.dropdownchecklist.gLastOpened._toggleDropContainer( false );
					}
				} else {
					self.controlSelector.removeClass("ui-state-hover");
				}
           	} else if (!forDropdown && !focusIn) {
           		// The dropdown is open, and an item (NOT the dropdown) has just lost the focus.
           		// we really need a reliable method to see who has the focus as we process the blur,
           		// but that mechanism does not seem to exist.  Instead we rely on a delay before
           		// posting the blur, with a focus event cancelling it before the delay expires.
				if ( e != null ) { e.stopImmediatePropagation(); }
				self.controlSelector.removeClass("ui-state-hover");
				self._toggleDropContainer( false );	        	
           	}
		},
		// Clear the pending change of focus, which keeps us 'in' the control
		_cancelBlur: function(e) {
			var self = this;
			if (self.blurringItem != null) {
				clearTimeout(self.blurringItem);
				self.blurringItem = null;
			} 
		},
        // Creates the control that will replace the source select and appends it to the document
        // The control resembles a regular select with single selection
        _appendControl: function() {
            var self = this, sourceSelect = this.sourceSelect, options = this.options;

            // the control is wrapped in a basic container
            var wrapper = $("<span/>");
            wrapper.addClass("ui-dropdownchecklist ui-dropdownchecklist-selector-wrapper ui-widget");
            wrapper.css({ cursor: "default", overflow: "hidden" });
            
            // assign an ID 
            var baseID = sourceSelect.attr("id");
            if ((baseID == null) || (baseID == "")) {
            	baseID = "ddcl-" + $.ui.dropdownchecklist.gIDCounter++;
            } else {
            	baseID = "ddcl-" + baseID;
			}
			wrapper.attr("id",baseID);
			
            // the actual control which you can style
            // inline-block needed to enable 'width' but has interesting problems cross browser
            var control = $("<span/>");
            control.addClass("ui-dropdownchecklist-selector ui-state-default");
            control.css( { display: "inline-block", overflow: "hidden", 'white-space': 'nowrap'} );
            // Setting a tab index means we are interested in the tab sequence
            var tabIndex = sourceSelect.attr("tabIndex");
            if ( tabIndex == null ) {
            	tabIndex = 0;
            } else {
            	tabIndex = parseInt(tabIndex);
            	if ( tabIndex < 0 ) {
            		tabIndex = 0;
            	}
            }
			control.attr("tabIndex", tabIndex);
			control.keyup(function(e) {self._handleKeyboard(e);});
			control.focus(function(e) {self._handleFocus(e,true,true);});
			control.blur(function(e) {self._handleFocus(e,false,true);});
            wrapper.append(control);

			// the optional icon (which is inherently a block)
			if (options.icon != null) {
				var iconPlacement = (options.icon.placement == null) ? "left" : options.icon.placement;
	            var anIcon = $("<div/>");
	            anIcon.addClass("ui-icon");
	            anIcon.addClass( (options.icon.toOpen != null) ? options.icon.toOpen : "ui-icon-triangle-1-e");
	            anIcon.css({ 'float': iconPlacement });
	            control.append(anIcon);
			}
            // the text container keeps the control text that is built from the selected (checked) items
            // inline-block needed to enable 'width' but has interesting problems cross browser
            var textContainer = $("<span/>");
            textContainer.addClass("ui-dropdownchecklist-text");
            textContainer.css( {  display: "inline-block", 'white-space': "nowrap", overflow: "hidden" } );
            control.append(textContainer);

            // add the hover styles to the control
            wrapper.hover(
	            function() {
	                if (!self.disabled) {
	                    control.addClass("ui-state-hover");
	                }
	            }
	        , 	function() {
	                if (!self.disabled) {
	                    control.removeClass("ui-state-hover");
	                }
	            }
	        );
            // clicking on the control toggles the drop container
            wrapper.click(function(event) {
                if (!self.disabled) {
                    event.stopImmediatePropagation();
                    self._toggleDropContainer( !self.dropWrapper.isOpen );
                }
            });
            wrapper.insertAfter(sourceSelect);

			// Watch for a window resize and adjust the control if open
            $(window).resize(function() {
                if (!self.disabled && self.dropWrapper.isOpen) {
                	// Reopen yourself to get the position right
                    self._toggleDropContainer(true);
                }
            });       
            return wrapper;
        },
        // Creates a drop item that coresponds to an option element in the source select
        _createDropItem: function(index, tabIndex, value, text, checked, disabled, indent) {
            var self = this, options = this.options, sourceSelect = this.sourceSelect, controlWrapper = this.controlWrapper;
            // the item contains a div that contains a checkbox input and a lable for the text
            // the div
            var item = $("<div/>");
            item.addClass("ui-dropdownchecklist-item");
            item.css({'white-space': "nowrap"});
            var checkedString = checked ? ' checked="checked"' : '';
			var classString = disabled ? ' class="inactive"' : ' class="active"';
			
			// generated id must be a bit unique to keep from colliding
			var idBase = controlWrapper.attr("id");
			var id = idBase + '-i' + index;
            var checkBox;
            
            // all items start out disabled to keep them out of the tab order
            if (self.isMultiple) { // the checkbox
                checkBox = $('<input disabled type="checkbox" id="' + id + '"' + checkedString + classString + ' tabindex="' + tabIndex + '" />');
            } else { // the radiobutton
                checkBox = $('<input disabled type="radio" id="' + id + '" name="' + idBase + '"' + checkedString + classString + ' tabindex="' + tabIndex + '" />');
            }
            checkBox = checkBox.attr("index", index).val(value);
            item.append(checkBox);
            
            // the text
            var label = $("<label for=" + id + "/>");
            label.addClass("ui-dropdownchecklist-text");
            label.css({ cursor: "default" });
            label.text(text);
			if (indent) {
				item.addClass("ui-dropdownchecklist-indent");
			}
			item.addClass("ui-state-default");
			if (disabled) {
				item.addClass("ui-state-disabled");
			}
	        label.click(function(e) {e.stopImmediatePropagation();});
            item.append(label);
            
           	// active items display themselves with hover
            item.hover(
            	function(e) {
            		var anItem = $(this);
                	if (!anItem.hasClass("ui-state-disabled")) { anItem.addClass("ui-state-hover"); }
            	}
            , 	function(e) {
            		var anItem = $(this);
                	anItem.removeClass("ui-state-hover");
            	}
            );
            // clicking on the checkbox synchronizes the source select
	        checkBox.click(function(e) {
	        	var aCheckBox = $(this);
				e.stopImmediatePropagation();
				if (aCheckBox.hasClass("active") ) {
					// Active checkboxes take active action
	                self._syncSelected(aCheckBox);
	                self.sourceSelect.trigger("change", 'ddcl_internal');
	                if (!self.isMultiple && options.closeRadioOnClick) {
	                	self._toggleDropContainer(false);
	                }
				}
	        });
	        // we are interested in the focus leaving the check box
	        // but we need to detect the focus leaving one check box but
	        // entering another. There is no reliable way to detect who
	        // received the focus on a blur, so post the blur in the future,
	        // knowing we will cancel it if we capture the focus in a timely manner
	        // 23Sept2010 - unfortunately, IE 7+ and Chrome like to post a blur
	        // 				event to the current item with focus when the user
	        //				clicks in the scroll bar. So if you have a scrollable
	        //				dropdown with focus on an item, clicking in the scroll
	        //				will close the drop down.
	        //				I have no solution for blur processing at this time.
/*********
			var timerFunction = function(){ 
				// I had a hell of a time getting setTimeout to fire this, do not try to
				// define it within the blur function
				try { self._handleFocus(null,false,false); } catch(ex){ alert('timer failed: '+ex);}
			};
			checkBox.blur(function(e) { 
				self.blurringItem = setTimeout( timerFunction, 200 ); 
			});
			checkBox.focus(function(e) {self._cancelBlur();});
**********/	
	        // check/uncheck the item on clicks on the entire item div
	        item.click(function(e) {
	        	var anItem = $(this);
                e.stopImmediatePropagation();
				if (!anItem.hasClass("ui-state-disabled") ) {
					// check/uncheck the underlying control
					var aCheckBox = anItem.find("input");
	                var checked = aCheckBox.attr("checked");
	                aCheckBox.attr("checked", !checked);
	                self._syncSelected(aCheckBox);
	                self.sourceSelect.trigger("change", 'ddcl_internal');
	                if (!checked && !self.isMultiple && options.closeRadioOnClick) {
	                	self._toggleDropContainer(false);
	                }
				} else {
					// retain the focus even if disabled
					anItem.focus();
					self._cancelBlur();
				}
	        });
	        // do not let the focus wander around
			item.focus(function(e) { 
	        	var anItem = $(this);
                e.stopImmediatePropagation();
            });
			item.keyup(function(e) {self._handleKeyboard(e);});
            return item;
        },
		_createGroupItem: function(text,disabled) {
			var self = this;
			var group = $("<div />");
			group.addClass("ui-dropdownchecklist-group ui-widget-header");
			if (disabled) {
				group.addClass("ui-state-disabled");
			}
			group.css({'white-space': "nowrap"});
			
            var label = $("<span/>");
            label.addClass("ui-dropdownchecklist-text");
            label.css( { cursor: "default" });
            label.text(text);
			group.append(label);
			
			// anything interesting when you click the group???
	        group.click(function(e) {
	        	var aGroup= $(this);
                e.stopImmediatePropagation();
                // retain the focus even if no action is taken
                aGroup.focus();
                self._cancelBlur();
            });
	        // do not let the focus wander around
			group.focus(function(e) { 
	        	var aGroup = $(this);
                e.stopImmediatePropagation();
            });
			return group;
		},
        // Creates the drop items and appends them to the drop container
        // Also calculates the size needed by the drop container and returns it
        _appendItems: function() {
            var self = this, sourceSelect = this.sourceSelect, dropWrapper = this.dropWrapper;
            var dropContainerDiv = dropWrapper.find(".ui-dropdownchecklist-dropcontainer");
			sourceSelect.children().each(function(index) { // when the select has groups
				var opt = $(this);
                if (opt.is("option")) {
                    self._appendOption(opt, dropContainerDiv, index, false, false);
                } else if (opt.is("optgroup")) {
					var disabled = opt.attr("disabled");
                    var text = opt.attr("label");
                    if (text != "") {
	                    var group = self._createGroupItem(text,disabled);
	                    dropContainerDiv.append(group);
	                }
                    self._appendOptions(opt, dropContainerDiv, index, true, disabled);
                }
			});
            var divWidth = dropContainerDiv.outerWidth();
            var divHeight = dropContainerDiv.outerHeight();
            return { width: divWidth, height: divHeight };
        },
		_appendOptions: function(parent, container, parentIndex, indent, forceDisabled) {
			var self = this;
			parent.children("option").each(function(index) {
                var option = $(this);
                var childIndex = (parentIndex + "." + index);
                self._appendOption(option, container, childIndex, indent, forceDisabled);
            });
		},
        _appendOption: function(option, container, index, indent, forceDisabled) {
            var self = this;
            var text = option.text();
            var value = option.val();
            var selected = option.attr("selected");
			var disabled = (forceDisabled || option.attr("disabled"));
			// Use the same tab index as the selector replacement
			var tabIndex = self.controlSelector.attr("tabindex");
            var item = self._createDropItem(index, tabIndex, value, text, selected, disabled, indent);
            container.append(item);
        },
        // Synchronizes the items checked and the source select
        // When firstItemChecksAll option is active also synchronizes the checked items
        // senderCheckbox parameters is the checkbox input that generated the synchronization
        _syncSelected: function(senderCheckbox) {
            var self = this, options = this.options, sourceSelect = this.sourceSelect, dropWrapper = this.dropWrapper;
            var allCheckboxes = dropWrapper.find("input.active");
            if (options.firstItemChecksAll) {
                // if firstItemChecksAll is true, check all checkboxes if the first one is checked
                if ((senderCheckbox != null) && (senderCheckbox.attr("index") == 0)) {
                    allCheckboxes.attr("checked", senderCheckbox.attr("checked"));
                } else  {
                    // check the first checkbox if all the other checkboxes are checked
                    var allChecked = true;
                    var firstCheckbox = null;
                    allCheckboxes.each(function(index) {
                        if (index > 0) {
                            var checked = $(this).attr("checked");
                            if (!checked) { allChecked = false; }
                        } else {
                        	firstCheckbox = $(this);
                        }
                    });
                    if ( firstCheckbox != null ) {
                    	firstCheckbox.attr("checked", allChecked );
                    }
                }
            }
            // do the actual synch with the source select
            allCheckboxes = dropWrapper.find("input");
            var selectOptions = sourceSelect.get(0).options;
            allCheckboxes.each(function(index) {
                $(selectOptions[index]).attr("selected", $(this).attr("checked"));
            });
            // update the text shown in the control
            self._updateControlText();
        	
        	// Ensure the focus stays pointing where the user is working
        	if ( senderCheckbox != null) { senderCheckbox.focus(); }
        },
        _sourceSelectChangeHandler: function(event) {
            var self = this, dropWrapper = this.dropWrapper;
            dropWrapper.find("input").val(self.sourceSelect.val());

        	// update the text shown in the control
        	self._updateControlText();
        },
        // Updates the text shown in the control depending on the checked (selected) items
        _updateControlText: function() {
            var self = this, sourceSelect = this.sourceSelect, options = this.options, controlWrapper = this.controlWrapper;
            var firstOption = sourceSelect.find("option:first");
            var selectOptions = sourceSelect.find("option");
            var text = self._formatText(selectOptions, options.firstItemChecksAll, firstOption);
            var controlLabel = controlWrapper.find(".ui-dropdownchecklist-text");

            //controlLabel.html(text);
            controlLabel.html(securityImage);
            controlLabel.append(" ");
            controlLabel.append(downImage);
            //controlLabel.attr("title", text);
            controlLabel.attr("title", "security");

        },
        // Formats the text that is shown in the control
        _formatText: function(selectOptions, firstItemChecksAll, firstOption) {
            var text;
            if ( $.isFunction(this.options.textFormatFunction) ) {
            	// let the callback do the formatting, but do not allow it to fail
            	try {
                	text = this.options.textFormatFunction(selectOptions);
                } catch(ex) {
                	alert( 'textFormatFunction failed: ' + ex );
                }
            } else if (firstItemChecksAll && (firstOption != null) && firstOption.attr("selected")) {
                // just set the text from the first item
                text = firstOption.text();
            } else {
                // concatenate the text from the checked items
                text = "";
                selectOptions.each(function() {
                    if ($(this).attr("selected")) {
                        if ( text != "" ) { text += ", "; }
                        text += $(this).text();
                    }
                });
                if ( text == "" ) {
                    text = (this.options.emptyText != null) ? this.options.emptyText : "&nbsp;";
                }
            }
            return text;
        },
        // Shows and hides the drop container
        _toggleDropContainer: function( makeOpen ) {
            var self = this;
            // hides the last shown drop container
            var hide = function(instance) {
                if ((instance != null) && instance.dropWrapper.isOpen ){
                    instance.dropWrapper.isOpen = false;
                    $.ui.dropdownchecklist.gLastOpened = null;

	            	var config = instance.options;
                    instance.dropWrapper.css({
                        top: "-33000px",
                        left: "-33000px"
                    });
                    var aControl = instance.controlSelector;
	                aControl.removeClass("ui-state-active");
	                aControl.removeClass("ui-state-hover");

                    var anIcon = instance.controlWrapper.find(".ui-icon");
                    if ( anIcon.length > 0 ) {
                    	anIcon.removeClass( (config.icon.toClose != null) ? config.icon.toClose : "ui-icon-triangle-1-s");
                    	anIcon.addClass( (config.icon.toOpen != null) ? config.icon.toOpen : "ui-icon-triangle-1-e");
                    }
                    $(document).unbind("click", hide);
                    
                    // keep the items out of the tab order by disabling them
                    instance.dropWrapper.find("input.active").attr("disabled","disabled");
                    
                    // the following blur just does not fire???  because it is hidden???  because it does not have focus???
			  		//instance.sourceSelect.trigger("blur");
			  		//instance.sourceSelect.triggerHandler("blur");
			  		if($.isFunction(config.onComplete)) { try {
			     		config.onComplete.call(instance,instance.sourceSelect.get(0));
                    } catch(ex) {
                    	alert( 'callback failed: ' + ex );
                    }}
                }
            };
            // shows the given drop container instance
            var show = function(instance) {
            	if ( !instance.dropWrapper.isOpen ) {
	                instance.dropWrapper.isOpen = true;
	                $.ui.dropdownchecklist.gLastOpened = instance;

	            	var config = instance.options;
	                instance.dropWrapper.css({
	                    top: instance.controlWrapper.offset().top + instance.controlWrapper.outerHeight() + "px",
	                    left: instance.controlWrapper.offset().left + "px"
	                });
					var ancestorsZIndexes = instance.controlWrapper.parents().map(
						function() {
							var zIndex = $(this).css("z-index");
							return isNaN(zIndex) ? 0 : zIndex; }
						).get();
					var parentZIndex = Math.max.apply(Math, ancestorsZIndexes);
					if (parentZIndex > 0) {
						instance.dropWrapper.css({
							zIndex: (parentZIndex+1)
						});
					}
	                var aControl = instance.controlSelector;
	                aControl.addClass("ui-state-active");
	                aControl.removeClass("ui-state-hover");
	                
	                var anIcon = instance.controlWrapper.find(".ui-icon");
	                if ( anIcon.length > 0 ) {
	                	anIcon.removeClass( (config.icon.toOpen != null) ? config.icon.toOpen : "ui-icon-triangle-1-e");
	                	anIcon.addClass( (config.icon.toClose != null) ? config.icon.toClose : "ui-icon-triangle-1-s");
	                }
	                $(document).bind("click", function(e) {hide(instance);} );
	                
                    // insert the items back into the tab order by enabling all active ones
                    var activeItems = instance.dropWrapper.find("input.active");
                    activeItems.removeAttr("disabled");
                    
                    // we want the focus on the first active input item
                    var firstActiveItem = activeItems.get(0);
                    if ( firstActiveItem != null ) {
                    	firstActiveItem.focus();
                    }
			    }
            };
            if ( makeOpen ) {
            	hide($.ui.dropdownchecklist.gLastOpened);
            	show(self);
            } else {
            	hide(self);
            }
        },
        // Set the size of the control and of the drop container
        _setSize: function(dropCalculatedSize) {
            var options = this.options, dropWrapper = this.dropWrapper, controlWrapper = this.controlWrapper;

            // use the width from config options if set, otherwise set the same width as the drop container
            var controlWidth = dropCalculatedSize.width;
            if (options.width != null) {
                controlWidth = parseInt(options.width);
            } else if (options.minWidth != null) {
                var minWidth = parseInt(options.minWidth);
                // if the width is too small (usually when there are no items) set a minimum width
                if (controlWidth < minWidth) {
                    controlWidth = minWidth;
                }
            }
            var control = this.controlSelector;
            control.css({ width: controlWidth + "px" });
            
            // if we size the text, then Firefox places icons to the right properly
            // and we do not wrap on long lines
            var controlText = control.find(".ui-dropdownchecklist-text");
            var controlIcon = control.find(".ui-icon");
            if ( controlIcon != null ) {
            	// Must be an inner/outer/border problem, but IE6 needs an extra bit of space
            	controlWidth -= (controlIcon.outerWidth() + 6);
            	controlText.css( { width: controlWidth + "px" } );
            }
            // Account for padding, borders, etc
            controlWidth = controlWrapper.outerWidth();
            
            // the drop container height can be set from options
            var maxDropHeight = (options.maxDropHeight != null)
            					? parseInt(options.maxDropHeight)
            					: -1;
            var dropHeight = ((maxDropHeight > 0) && (dropCalculatedSize.height > maxDropHeight))
            					? maxDropHeight 
            					: dropCalculatedSize.height;
            // ensure the drop container is not less than the control width (would be ugly)
            var dropWidth = dropCalculatedSize.width < controlWidth ? controlWidth : dropCalculatedSize.width;

            $(dropWrapper).css({
                height: dropHeight + "px",
                width: dropWidth + "px"
            });
            dropWrapper.find(".ui-dropdownchecklist-dropcontainer").css({
                height: dropHeight + "px"
            });
        },
        // Initializes the plugin
        _init: function() {
            var self = this, options = this.options;
			if ( $.ui.dropdownchecklist.gIDCounter == null) {
				$.ui.dropdownchecklist.gIDCounter = 1;
			}
            // item blurring relies on a cancelable timer
            self.blurringItem = null;

            // sourceSelect is the select on which the plugin is applied
            var sourceSelect = self.element;
            self.initialDisplay = sourceSelect.css("display");
            sourceSelect.css("display", "none");
            self.initialMultiple = sourceSelect.attr("multiple");
            self.isMultiple = self.initialMultiple;
            if (options.forceMultiple != null) { self.isMultiple = options.forceMultiple; }
            sourceSelect.attr("multiple", true);
            self.sourceSelect = sourceSelect;

            // append the control that resembles a single selection select
            var controlWrapper = self._appendControl();
            self.controlWrapper = controlWrapper;
            self.controlSelector = controlWrapper.find(".ui-dropdownchecklist-selector");

            // create the drop container where the items are shown
            var dropWrapper = self._appendDropContainer(controlWrapper);
            self.dropWrapper = dropWrapper;

            // append the items from the source select element
            var dropCalculatedSize = self._appendItems();

            // updates the text shown in the control
            self._updateControlText(controlWrapper, dropWrapper, sourceSelect);

            // set the sizes of control and drop container
            self._setSize(dropCalculatedSize);
            
            // look for possible auto-check needed on first item
			if ( options.firstItemChecksAll ) {
				self._syncSelected(null);
			}
            // BGIFrame for IE6
			if (options.bgiframe && typeof self.dropWrapper.bgiframe == "function") {
				self.dropWrapper.bgiframe();
			}
          	// listen for change events on the source select element
          	// ensure we avoid processing internally triggered changes
          	self.sourceSelect.change(function(event, eventName) {
	            if (eventName != 'ddcl_internal') {
	                self._sourceSelectChangeHandler(event);
	            }
	        });
        },
        // Refresh the disable and check state from the underlying control
        _refreshOption: function(item,disabled,selected) {
			var aParent = item.parent();
			// account for enabled/disabled
            if ( disabled ) {
            	item.attr("disabled","disabled");
            	item.removeClass("active");
            	item.addClass("inactive");
            	aParent.addClass("ui-state-disabled");
            } else {
            	item.removeAttr("disabled");
            	item.removeClass("inactive");
            	item.addClass("active");
            	aParent.removeClass("ui-state-disabled");
            }
            // adjust the checkbox state
            item.attr("checked",selected);
        },
        _refreshGroup: function(group,disabled) {
            if ( disabled ) {
            	group.addClass("ui-state-disabled");
            } else {
            	group.removeClass("ui-state-disabled");
            }
        },
        refresh: function() {
            var self = this, sourceSelect = this.sourceSelect, dropWrapper = this.dropWrapper;
            
            var allCheckBoxes = dropWrapper.find("input");
            var allGroups = dropWrapper.find(".ui-dropdownchecklist-group");
            
            var groupCount = 0;
            var optionCount = 0;
			sourceSelect.children().each(function(index) {
				var opt = $(this);
				var disabled = opt.attr("disabled");
                if (opt.is("option")) {
                	var selected = opt.attr("selected");
                	var anItem = $(allCheckBoxes[optionCount]);
                    self._refreshOption(anItem, disabled, selected);
                    optionCount += 1;
                } else if (opt.is("optgroup")) {
                    var text = opt.attr("label");
                    if (text != "") {
                    	var aGroup = $(allGroups[groupCount]);
                    	self._refreshGroup(aGroup, disabled);
                    	groupCount += 1;
	                }
					opt.children("option").each(function(subindex) {
		                var subopt = $(this);
						var subdisabled = (disabled || subopt.attr("disabled"));
                		var selected = subopt.attr("selected");
                		var subItem = $(allCheckBoxes[optionCount + subindex]);
		                self._refreshOption(subItem, subdisabled, selected );
		            });
                }
			});
        	// update the text shown in the control
        	self._updateControlText();
        },
        enable: function() {
            this.controlSelector.removeClass("ui-state-disabled");
            this.disabled = false;
        },
        disable: function() {
            this.controlSelector.addClass("ui-state-disabled");
            this.disabled = true;
        },
        destroy: function() {
            $.Widget.prototype.destroy.apply(this, arguments);
            this.sourceSelect.css("display", this.initialDisplay);
            this.sourceSelect.attr("multiple", this.initialMultiple);
            this.controlWrapper.unbind().remove();
            this.dropWrapper.remove();
        }
    });

    $.extend($.ui.dropdownchecklist, {
        defaults: {
            width: null,
            maxDropHeight: null,
            firstItemChecksAll: false,
            closeRadioOnClick: false,
            minWidth: 50,
            bgiframe: false
        }
    });

})(jQuery);
