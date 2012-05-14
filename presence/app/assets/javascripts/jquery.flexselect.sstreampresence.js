/**
 * flexselect: a jQuery plugin, version: 0.3 (2011-12-17)
 * @requires jQuery v1.3 or later
 *
 * FlexSelect is a jQuery plugin that makes it easy to convert a select box into
 * a Quicksilver-style, autocompleting, flex matching selection tool.
 *
 * For usage and examples, visit:
 * http://rmm5t.github.com/jquery-flexselect/
 *
 * Licensed under the MIT:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright (c) 2009-2012, Ryan McGeary (ryan -[at]- mcgeary [*dot*] org)
 */
(function($) {
  $.flexselect = function(select, options) { this.init(select, options); };

  $.extend($.flexselect.prototype, {
    settings: {
      allowMismatch: false,
      selectedClass: "flexselect_selected",
      dropdownClass: "flexselect_dropdown",
			defaultmessage: "No results",
      inputIdTransform:    function(id)   { return id + "_flexselect"; },
      inputNameTransform:  function(name) { return; },
      dropdownIdTransform: function(id)   { return id + "_flexselect_dropdown"; }
    },
    select: null,
    input: null,
    hidden: null,
    dropdown: null,
    dropdownList: null,
    cache: [],
    results: [],
    lastAbbreviation: null,
    abbreviationBeforeFocus: null,
    selectedIndex: 0,
    picked: false,
    dropdownMouseover: false, // Workaround for poor IE behaviors

    init: function(select, options) {
      this.settings = $.extend({}, this.settings, options);
      this.select = $(select);
      this.preloadCache();
      this.renderControls();
      this.wire();
    },

    preloadCache: function() {
      this.cache = this.select.children("option").map(function() {
        return { name: $.trim($(this).text()), value: $(this).val(), score: 0.0 };
      });
    },
		
		//preloadCache: function() {
    //  this.cache = this.select.children("option").map(function() {
		//		var slug = $(this).val();
				
		//		if(slug!=""){
		//			var code = $(getAvatarBoxFromSlug(slug)).html();
		//			return { name: code, value: slug, score: 0.0 };
		//		}

        //return { name: ($(this).html()), value: $(this).val(), score: 0.0 };
    //  });
    //},

    renderControls: function() {
      var selected = this.select.children("option:selected");

      this.hidden = $("<input type='hidden'/>").attr({
        id: this.select.attr("id"),
        name: this.select.attr("name")
      }).val(selected.val());

      this.input = $("<input type='text' autocomplete='off' />").attr({
        id: this.settings.inputIdTransform(this.select.attr("id")),
        name: this.settings.inputNameTransform(this.select.attr("name")),
        accesskey: this.select.attr("accesskey"),
        tabindex: this.select.attr("tabindex"),
				placeholder: this.select.attr("placeholder"),
        style: this.select.attr("style")
      }).addClass(this.select.attr("class")).val($.trim(selected.text()));

      this.dropdown = $("<div></div>").attr({
        id: this.settings.dropdownIdTransform(this.select.attr("id"))
      }).addClass(this.settings.dropdownClass);
      this.dropdownList = $("<ul></ul>");
      this.dropdown.append(this.dropdownList);

      this.select.after(this.input).after(this.hidden).remove();
      $("body").append(this.dropdown);
    },

    wire: function() {
      var self = this;

      this.input.click(function() {
        self.lastAbbreviation = null;
        self.focus();
				if (!self.picked) self.filterResults();
      });

      this.input.mouseup(function(event) {
        // This is so Safari selection actually occurs.
        event.preventDefault();
      });

      this.input.focus(function() {
        self.abbreviationBeforeFocus = self.input.val();
        self.input.select();
        //if (!self.picked) self.filterResults();
      });

      this.input.blur(function() {
        if (!self.dropdownMouseover) {
          self.hide();
          if (!self.settings.allowMismatch && !self.picked) self.reset();
        }
      });

      this.dropdownList.mouseover(function (event) {
        if (event.target.tagName == "LI") {
          var rows = self.dropdown.find("li");
          self.markSelected(rows.index($(event.target)));
        }
      });
			
      this.dropdownList.mouseleave(function () {
        self.markSelected(-1);
      });
      this.dropdownList.mouseup(function (event) {
        self.pickSelected();
        self.focusAndHide();
      });
      this.dropdown.mouseover(function (event) {
        self.dropdownMouseover = true;
      });
      this.dropdown.mouseleave(function (event) {
        self.dropdownMouseover = false;
      });
      this.dropdown.mousedown(function (event) {
        event.preventDefault();
      });

      this.input.keyup(function(event) {
        switch (event.keyCode) {
          case 13: // return
            event.preventDefault();
            self.pickSelected();
            self.focusAndHide();
            break;
          case 27: // esc
            event.preventDefault();
            self.reset();
            self.focusAndHide();
            break;
          default:
            self.filterResults();
            break;
        }
      });

      this.input.keydown(function(event) {
        switch (event.keyCode) {
          case 9:  // tab
            self.pickSelected();
            self.hide();
            break;
          case 33: // pgup
            event.preventDefault();
            self.markFirst();
            break;
          case 34: // pgedown
            event.preventDefault();
            self.markLast();
            break;
          case 38: // up
            event.preventDefault();
            self.moveSelected(-1);
            break;
          case 40: // down
            event.preventDefault();
            self.moveSelected(1);
            break;
          case 13: // return
          case 27: // esc
            event.preventDefault();
            event.stopPropagation();
            break;
        }
      });
    },

    filterResults: function() {
      var abbreviation = this.input.val();
      if (abbreviation == this.lastAbbreviation) return;

      var results = [];
      $.each(this.cache, function() {
        this.score = LiquidMetal.score(this.name, abbreviation);
        if (this.score > 0.0) results.push(this);
      });
			
			if (results.length==0){
				var defaultOption = { name: this.settings.defaultmessage, value: "ZERO_CONTACTS", score: 9.9 };
				results.push(defaultOption);
			}
			
      this.results = results;
      this.sortResults();
      this.renderDropdown();
      this.markFirst();
      this.lastAbbreviation = abbreviation;
      this.picked = false;
    },

    sortResults: function() {
      this.results.sort(function(a, b) { return b.score - a.score; });
    },

    renderDropdown: function() {
      var dropdownBorderWidth = this.dropdown.outerWidth() - this.dropdown.innerWidth();
      var inputOffset = this.input.offset();
      this.dropdown.css({
        width: (this.input.outerWidth() - dropdownBorderWidth) + "px",
        top: (inputOffset.top + this.input.outerHeight()) + "px",
        left: inputOffset.left + "px"
      });

      var list = this.dropdownList.html("");

      if (this.results.length > 0) {
				$.each(this.results, function() {
	        list.append($("<li/>").html(this.name));
	      });
			}
			
      this.dropdown.show();
    },

    markSelected: function(n) {
      if (n > this.results.length) return;

      var rows = this.dropdown.find("li");
      rows.removeClass(this.settings.selectedClass);
      this.selectedIndex = n;

      if (n >= 0) $(rows[n]).addClass(this.settings.selectedClass);
    },

    pickSelected: function() {
      var selected = this.results[this.selectedIndex];
      if (selected) {
        //this.input.val(selected.name);
        //this.picked = true;
				this.hidden.val(selected.value);
        this.input.val("");
				if(typeof PRESENCE.UIMANAGER.changeSelectContactValue == "function"){
          return PRESENCE.UIMANAGER.changeSelectContactValue(selected.name,selected.value);
        } 
      } else if (this.settings.allowMismatch) {
        this.hidden.val("");
      } else {
        this.reset();
      }
    },

    hide: function() {
      this.dropdown.hide();
      this.lastAbbreviation = null;
    },

    moveSelected: function(n) { this.markSelected(this.selectedIndex+n); },
    markFirst:    function()  { this.markSelected(0); },
    markLast:     function()  { this.markSelected(this.results.length - 1); },
    reset:        function()  { this.input.val(this.abbreviationBeforeFocus); },
    focus:        function()  { this.input.focus(); },
    focusAndHide: function()  { this.hide(); //this.focus();
    }
  });

  $.fn.flexselect = function(options) {
    this.each(function() {
      if (this.tagName == "SELECT") new $.flexselect(this, options);
    });
    return this;
  };
})(jQuery);
