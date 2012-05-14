/*
 * Copyright 2010, Wen Pu (dexterpu at gmail dot com)
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * Check out http://www.cs.illinois.edu/homes/wenpu1/chatbox.html for document
 *
 * Depends on jquery.ui.core, jquery.ui.widiget, jquery.ui.effect
 * 
 * Also uses some styles for jquery.ui.dialog
 * 
 */


// TODO: implement destroy()
(function($){
    $.widget("ui.chatbox", {
	options: {
	    id: null, //id for the DOM element
	    title: null, // title of the chatbox
	    user: null, // can be anything associated with this chatbox
	    hidden: false,
	    offset: 0, // relative to right edge of the browser window
	    width: 230, // width of the chatbox
	    height: 400, // height of the chatbox
	    groupBox: false, //if a group Chatbox?
	    video: 0, // height of the videoBox
	    messageSent: function(id, user, msg){
		// override this
		this.boxManager.addMsg(user.first_name, msg);
	    },
	    boxClosed: function(id) {}, // called when the close icon is clicked
	    boxManager: {
		// thanks to the widget factory facility
		// similar to http://alexsexton.com/?p=51
		init: function(elem) {
		    this.elem = elem;
		},
		addMsg: function(peer, msg) {
		    var self = this;
		    var box = self.elem.uiChatboxLog;
		    var e = document.createElement('div');
				if((peer==null)||($(peer).html()=="")){
					var fContent = msg
				} else {
					var fContent = "<b>" + peer +":</b> " + msg
				}
		    $(e).html(fContent)
			.addClass("ui-chatbox-msg");
		    box.append(e);
		    self._scrollToBottom();

		    if(!self.elem.uiChatboxTitlebar.hasClass("ui-state-focus") && !self.highlightLock) {
			   self.highlightLock = true;
			   self.highlightBox();
		    }
		},
		highlightBox: function() {
		    this.elem.uiChatbox.addClass("ui-state-highlight");
		    var self = this;
				
				//Get highlight color from css
				var dummy_element = $("<p class=\"chatWindowhighlighted\"></div>");
        var options = {color: $(dummy_element).css("color")};
				
		    self.elem.uiChatboxTitlebar.effect("highlight", options, 300);
				
				
				if (((typeof PRESENCE.UTILITIES.mustBounceBoxForChatWindow == 'function')&&(PRESENCE.UTILITIES.mustBounceBoxForChatWindow(self)))||((typeof PRESENCE.UTILITIES.mustBounceBoxForChatWindow != 'function'))) {
					 self.elem.uiChatbox.effect("bounce", {times:3}, 300, function(){
           self.highlightLock = false;
           self._scrollToBottom();
          });
				} else {
					 self.highlightLock = false;
				}
		},
		toggleBox: function(show) {
		    this.elem.uiChatbox.toggle(show);
		},
		_scrollToBottom: function() {
		    var box = this.elem.uiChatboxLog;
		    box.scrollTop(box.get(0).scrollHeight);
		}
	    }
	},

	toggleContent: function(event) {
	    this.uiChatboxContent.toggle();
	    if(this.uiChatboxContent.is(":visible")) {
		    this.uiChatboxInputBox.focus();
	    }
	},

	widget: function() {
	    return this.uiChatbox
	},

	_create: function(){
	    var self = this,
	    options = self.options,
	    title = options.title || "No Title",
	    // chatbox
	    uiChatbox = (self.uiChatbox = $('<div></div>'))
		.appendTo(document.body)
		.addClass('ui-widget ' + 
			  'ui-corner-top ' + 
			  'ui-chatbox'
			 )
		.attr('outline', 0)
		.focusin(function(){
		    // ui-state-highlight is not really helpful here
		    self.uiChatbox.removeClass('ui-state-highlight');
		    self.uiChatboxTitlebar.addClass('ui-state-focus');
		})
		.focusout(function(){
		    self.uiChatboxTitlebar.removeClass('ui-state-focus');
		}),
	    // titlebar
	    uiChatboxTitlebar = (self.uiChatboxTitlebar = $('<div></div>'))
		.addClass('ui-widget-header ' +
			  'ui-corner-top ' +
			  'ui-chatbox-titlebar ' +
			  'ui-dialog-header' // take advantage of dialog header style
			 )
		.click(function(event) {
		    self.toggleContent(event);
		})
		.appendTo(uiChatbox),
	    uiChatboxTitle = (self.uiChatboxTitle = $('<span></span>'))
		.html(title)
		.appendTo(uiChatboxTitlebar),
	    uiChatboxTitlebarClose = (self.uiChatboxTitlebarClose = $('<a href="#"></a>'))
		.addClass('ui-corner-all ' +
			  'ui-chatbox-icon '
			 )
		.attr('role', 'button')
		.hover(function() {uiChatboxTitlebarClose.addClass('ui-state-hover');},
		       function() {uiChatboxTitlebarClose.removeClass('ui-state-hover');})
		// .focus(function() {
		//     uiChatboxTitlebarClose.addClass('ui-state-focus');
		// })
		// .blur(function() {
		//     uiChatboxTitlebarClose.removeClass('ui-state-focus');
		// })
		.click(function(event) {
		    uiChatbox.hide();
		    self.options.boxClosed(self.options.id);
		    return false;
		})
		.appendTo(uiChatboxTitlebar),
	    uiChatboxTitlebarCloseText = $('<span></span>')
		.addClass('ui-icon-closethick ' + 'chat-thick ' + 'chat-closethick')
		.text('close')
		.appendTo(uiChatboxTitlebarClose),
	    uiChatboxTitlebarMinimize = (self.uiChatboxTitlebarMinimize = $('<a href="#"></a>'))
		.addClass('ui-corner-all ' + 
			  'ui-chatbox-icon'
			 )
		.attr('role', 'button')
		.hover(function() {uiChatboxTitlebarMinimize.addClass('ui-state-hover');},
		       function() {uiChatboxTitlebarMinimize.removeClass('ui-state-hover');})
		// .focus(function() {
		//     uiChatboxTitlebarMinimize.addClass('ui-state-focus');
		// })
		// .blur(function() {
		//     uiChatboxTitlebarMinimize.removeClass('ui-state-focus');
		// })
		.click(function(event) {
		    self.toggleContent(event);
		    return false;
		})
		.appendTo(uiChatboxTitlebar),
	    uiChatboxTitlebarMinimizeText = $('<span></span>')
		.addClass('ui-icon-minusthick ' +  'chat-thick ' + ' chat-minusthick')
		.text('minimize')
		.appendTo(uiChatboxTitlebarMinimize),
	    
			//Video Menu button
			uiChatboxTitlebarVideo = (self.uiChatboxTitlebarVideo = $('<a href="#"></a>'))
      .addClass('ui-corner-all ' + 
        'ui-chatbox-icon' + ' ui-videobox-icon'
       )
      .attr('role', 'button')
      .hover(function() {uiChatboxTitlebarVideo.addClass('ui-state-hover');},
           function() {uiChatboxTitlebarVideo.removeClass('ui-state-hover');})
      .click(function(event) {
        PRESENCE.WINDOW.toggleVideoBox(self)
        return false;
      })
      .appendTo(uiChatboxTitlebar),
      uiChatboxTitlebarVideoText = $('<span></span>')
      .addClass('ui-icon-circle-triangle-e ' + 'chat-thick ' + ' chat-videothick' )
      .text('     ')
      .appendTo(uiChatboxTitlebarVideo),
			
			
			//Change video-window Menu button
      uiChatboxTitlebarVideoChange = (self.uiChatboxTitlebarVideoChange = $('<a href="#"></a>'))
      .addClass('ui-corner-all ' + 
        'ui-chatbox-icon' + ' ui-videobox-icon-change'
       )
      .attr('role', 'button')
      .hover(function() {uiChatboxTitlebarVideoChange.addClass('ui-state-hover');},
           function() {uiChatboxTitlebarVideoChange.removeClass('ui-state-hover');})
      .click(function(event) {
        PRESENCE.WINDOW.toggleVideoBoxChange(self)
        return false;
      })
      .appendTo(uiChatboxTitlebar),
      uiChatboxTitlebarVideoText = $('<span></span>')
      .addClass('ui-icon-newwin ' +  'chat-thick ' + ' chat-videoPublisherthick' )
      .text('')
      .appendTo(uiChatboxTitlebarVideoChange),
			
			
			//Games Menu button
      uiChatboxTitlebarGames = (self.uiChatboxTitlebarGames = $('<a href="#"></a>'))
      .addClass('ui-corner-all ' + 
        'ui-chatbox-icon' + ' ui-games-icon'
       )
      .attr('role', 'button')
      .hover(function() {uiChatboxTitlebarGames.addClass('ui-state-hover');},
           function() {uiChatboxTitlebarGames.removeClass('ui-state-hover');})
      .click(function(event) {
				PRESENCE.GAME.INTERFACE.pickGamesButton(self)
        return false;
      })
      .appendTo(uiChatboxTitlebar),
      uiChatboxTitlebarGamesText = $('<span></span>')
      .addClass('ui-icon-star ' +  'chat-thick ' + ' chat-gamesthick' )
      .text('')
      .appendTo(uiChatboxTitlebarGames),
			
			
			// content
	    uiChatboxContent = (self.uiChatboxContent = $('<div></div>'))
		.addClass('ui-widget-content ' +
			  'ui-chatbox-content '
			 )
		.appendTo(uiChatbox),
		
		
		//Notification div
    uiChatboxNotify = (self.uiChatboxNotify = $('<div></div>'))
    .addClass('ui-widget-content ' + 
       'ui-chatbox-notify'
       )
    .click(function(event) {
				PRESENCE.NOTIFICATIONS.onClickChatNotification(self.uiChatboxNotify)
    })
    .appendTo(uiChatboxContent),
		
		
		//VideoBox div
    uiVideobox = (self.uiVideobox = $('<div></div>'))
    .addClass('ui-widget-content ' + 
       'ui-videobox'
       )
    .click(function(event) {
        // anything?
        
    })
    .appendTo(uiChatboxContent),
		
		
		//ChatBoxLog
	    uiChatboxLog = (self.uiChatboxLog = self.element)
		//.show()
		.addClass('ui-widget-content '+
			  'ui-chatbox-log'
			 )
		.appendTo(uiChatboxContent),
		
		
	    uiChatboxInput = (self.uiChatboxInput = $('<div></div>'))
		.addClass('ui-widget-content ' + 
			 'ui-chatbox-input'
			 )
		.click(function(event) {
		    // anything?
		})
		.appendTo(uiChatboxContent),
	    uiChatboxInputBox = (self.uiChatboxInputBox = $('<textarea></textarea>'))
		.addClass('ui-widget-content ' + 
			  'ui-chatbox-input-box ' +
			  'ui-corner-all'
			 )
		.appendTo(uiChatboxInput)
	        .keydown(function(event) {
				    if(event.keyCode && event.keyCode == $.ui.keyCode.ENTER) {
							var userChatDataInputControlBoolean = (((typeof PRESENCE.UTILITIES.userChatDataInputControl == 'function')&&(PRESENCE.UTILITIES.userChatDataInputControl()))||((typeof PRESENCE.UTILITIES.userChatDataInputControl != 'function')));
							if (userChatDataInputControlBoolean) {
						  	msg = $.trim($(this).val());
						  	if (msg.length > 0) {
						  		self.options.messageSent(self.options.id, self.options.user, msg);
						  	}
						  	$(this).val('');
						  }
							return false;
				    }
		      })
		.focusin(function() {
		    uiChatboxInputBox.addClass('ui-chatbox-input-focus');
		    var box = $(this).parent().prev();
		    box.scrollTop(box.get(0).scrollHeight);
		})
		.focusout(function() {
		    uiChatboxInputBox.removeClass('ui-chatbox-input-focus');
		});

	    // disable selection
	    uiChatboxTitlebar.find('*').add(uiChatboxTitlebar).disableSelection();

	    // switch focus to input box when whatever clicked
	    uiChatboxContent.children().click(function(){
		    // click on any children, set focus on input box
		    self.uiChatboxInputBox.focus();
	    });

	    self._setWidth(self.options.width);
			self._setHeight(self.options.height);
			self._setVideo(self.options.video);
	    self._position(self.options.offset);

	    self.options.boxManager.init(self);

	    if(!self.options.hidden) {
		uiChatbox.show();
	    }
	},

	_setOption: function(option, value) {
	    if(value != null){
		  switch(option) {
				case "hidden":
				    if(value) {
					   this.uiChatbox.hide();
				    }
				    else {
					   this.uiChatbox.show();
				    }
				    break;
				case "offset":
				    this._position(value);
				    break;
				case "width":
				    this._setWidth(value);
				    break;
			  case "height":
            this._setHeight(value);
            break;
				case "video":
            this._setVideo(value);
            break;
			  case "groupBox":
            this._setGroupBox(value);
            break;
				}
	    }

	    $.Widget.prototype._setOption.apply(this, arguments);
	},

	_setWidth: function(width) {
	    this.uiChatboxTitlebar.width(width + "px");
	    this.uiChatboxLog.width(width + "px");
	    // this is a hack, but i can live with it so far
	    this.uiChatboxInputBox.css("width", (width - 14) + "px");
	},
	
	 _setHeight: function(height) {
      this.uiChatboxLog.height(height + "px");
  },
	
	_setGroupBox: function(groupBox) {
      this.uiChatboxLog.groupBox(groupBox);
  },
	
	_setVideo: function(videoHeight) {
      this.uiVideobox.height(videoHeight + "px");
			if (videoHeight==0){
				this.uiVideobox.hide();
			} else {
				this.uiVideobox.show();
			}
  },

	_position: function(offset) {
	    this.uiChatbox.css("right", offset);
	}
    });

}(jQuery));