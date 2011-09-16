/**
 FCBKcomplete v2.8.6 is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 - Jquery version required: 1.6.x
*/

/* Based on TextboxList by Guillermo Rauch http://devthought.com/ */

/**
 * json_url         - url to fetch json object
 * cache            - use cache
 * height           - maximum number of element shown before scroll will apear
 * newel            - show typed text like a element
 * firstselected    - automaticly select first element from dropdown
 * filter_case      - case sensitive filter
 * filter_selected  - filter selected items from list
 * complete_text    - text for complete page
 * maxshownitems    - maximum numbers that will be shown at dropdown list (less better performance)
 * onselect         - fire event on item select
 * onremove         - fire event on item remove
 * maxitimes        - maximum items that can be added
 * delay            - delay between ajax request (bigger delay, lower server time request)
 * addontab         - add first visible element on tab or enter hit
 * attachto         - after this element fcbkcomplete insert own elements
 * bricket          - use square bricket with select (needed for asp or php) enabled by default
 */

(function( $, undefined ) {
  $.fn.fcbkcomplete = function(opt) {
    return this.queue( function() {
      function init() {
        createFCBK();
        addInput(0);
      }

      function createFCBK() {
        holder = $('<ul class="holder"></ul>');
        if (options.attachto) {
          if (typeof(options.attachto) == "object") {
            options.attachto.append(holder);
          } else {
            $(options.attachto).append(holder);
          }
        } else {
          element.after(holder);
        }
        complete = $('<div class="facebook-auto">').append('<div class="default">' + options.complete_text + "</div>");
        complete.hover(function() {complete_hover = 0;}, function() {complete_hover = 1;});
        feed = $('<ul id="'+elemid+'_feed"></ul>');
        holder.after(complete.prepend(feed));
        feed.css("width", complete.width());
        elPrepare();
      }

      function elPrepare() {
        name = element.attr("name");
        if (options.bricket) {
          if (name.indexOf("[]") == -1) {
            name = name + "[]";
          }
        }

        var temp_elem = $('<'+element.get(0).tagName+' name="'+name+'" id="'+elemid+'" multiple="multiple" class="hidden">');
        
        $.each(element.children('option'), function(i, option) {
          option = $(option);
          temp_elem.data(option.val(), option.text());
          if (option.hasClass("selected")) {
            var id = addItem(option.text(), option.val(), true, option.hasClass("locked"));
            temp_elem.append('<option value="'+option.val()+'" selected="selected" id="opt_'+id+'"class="selected">'+option.text()+'</option>');
          }
        });
        
        element.after(temp_elem);
        element.remove();
        element = temp_elem;
        
        //public method to add new item
        $(element).bind("addItem", function(event, data) {
          addItem(data.title, data.value, 0, 0, 0);
        });
        
        //public method to remove item
        $(element).bind("removeItem", function(event, data) {
          var item = holder.children('li[rel=' + data.value + ']');
          if (item.length) {
            removeItem(item);
          }
        });
        
        //public method to remove item
        $(element).bind("destroy", function(event, data) {
          holder.remove();
          complete.remove();
          element.show();
        });
      }
      
      function addItem(title, value, preadded, locked, focusme) {
        if (!maxItems()) {
          return false;
        }
        var liclass = "bit-box" + (locked ? " locked": "");
        var id = randomId();
        var txt = document.createTextNode(xssDisplay(title));
        var aclose = $('<a class="closebutton" href="#"></a>');
        var li = $('<li class="'+liclass+'" rel="'+value+'" id="pt_'+id+'"></li>').prepend(txt).append(aclose);

        holder.append(li);

        aclose.click( function() {
          removeItem($(this).parent("li"));
          return false;
        });
        if (!preadded) {
          $("#" + elemid + "_annoninput").remove();
          addInput(focusme);
          var _item = $('<option value="'+xssDisplay(value, 1)+'" id="opt_'+id+'" class="selected" selected="selected">'+xssDisplay(title)+'</option>');
          element.append(_item);
          if (options.onselect) {
            funCall(options.onselect, _item);
          }
          element.change();
        }
        holder.children("li.bit-box.deleted").removeClass("deleted");
        feed.hide();
        return id;
      }

      function removeItem(item) {
        if (!item.hasClass('locked')) {
          item.fadeOut("fast");
          var id = item.attr('id');
          if (options.onremove) {
            var _item = id ?  $("#o" + id + "") : element.children("option[value=" + item.attr("rel") + "]");
            funCall(options.onremove, _item);
          }
          if (id) {
             $("#o" + id + "").remove();
          } else {
            element.children('option[value="' + item.attr("rel") + '"]').remove();
          }
          item.remove();
          element.change();
          deleting = 0;
        }
      }

      function addInput(focusme) {
        var li = $('<li class="bit-input" id="'+elemid + '_annoninput">');
        var input = $('<input type="text" class="maininput" size="1" autocomplete="off">');
        var getBoxTimeout = 0;

        holder.append(li.append(input));

        input.focus( function() {
          if (maxItems()) {
            complete.fadeIn("fast");
          }
        });
        
        input.blur( function() {
          if (complete_hover) {
            complete.fadeOut("fast");
          } else {
            input.focus();
          }
        });
        
        holder.click( function() {
          input.focus();
          if (feed.length && input.val().length) {
            feed.show();
          } else {
            feed.hide();
            complete.children(".default").show();
          }
        });
        
        input.keypress( function(event) {
          if (event.keyCode == _key.enter) {
            return false;
          }
          //auto expand input
          input.attr("size", input.val().length + 1);
        });

        input.keyup( function(event) {
          var etext = xssPrevent(input.val(), 1);
          
          if (event.keyCode == _key.backspace && etext.length == 0) {
            feed.hide();
            if (!holder.children("li.bit-box:last").hasClass('locked')) {
              if (holder.children("li.bit-box.deleted").length == 0) {
                holder.children("li.bit-box:last").addClass("deleted");
                return false;
              } else {
                if (deleting) {
                  return;
                }
                deleting = 1;
                holder.children("li.bit-box.deleted").fadeOut("fast", function() {
                  removeItem($(this));
                  return false;
                });
              }
            }
          }

          if (event.keyCode != _key.downarrow && event.keyCode != _key.uparrow && event.keyCode!= _key.leftarrow && event.keyCode!= _key.rightarrow && etext.length != 0) {
            counter = 0;
            if (options.json_url && maxItems()) {
              if (options.cache && json_cache_object.get(etext)) {
                addMembers(etext);
                bindEvents();
              } else {
                getBoxTimeout++;
                var getBoxTimeoutValue = getBoxTimeout;
                setTimeout( function() {
                  if (getBoxTimeoutValue != getBoxTimeout) return;
                  $.getJSON(options.json_url, {"tag": xssDisplay(etext)}, function(data) {
                    addMembers(etext, data);
                    json_cache_object.set(etext, 1);
                    bindEvents();
                  });
                }, options.delay);
              }
            } else {
              addMembers(etext);
              bindEvents();
            }
            complete.children(".default").hide();
            feed.show();
          }
        });
        if (focusme) {
          setTimeout( function() {
            input.focus();
            complete.children(".default").show();
          }, 1);
        }
      }

      function addMembers(etext, data) {
        feed.html('');
        if (!options.cache && data != null) {
          cache.clear();
        }
        addTextItem(etext);
        if (data != null && data.length) {
          $.each(data, function(i, val) {
            cache.set(xssPrevent(val.key), xssPrevent(val.value));
          });
        }        
        var maximum = options.maxshownitems < cache.length() ? options.maxshownitems: cache.length();
        var content = '';
        $.each(cache.search(etext), function (i, object) {
          if (options.filter_selected && element.children("option[value=" + object.key + "]").hasClass("selected")) {
            //nothing here...
          } else {
            content += '<li rel="' + object.key + '">' + xssDisplay(itemIllumination(object.value, etext)) + '</li>';
            counter++;
            maximum--;
          }
        });        
        feed.append(content);
        if (options.firstselected) {
          focuson = feed.children("li:visible:first");
          focuson.addClass("auto-focus");
        }
        
        if (counter > options.height) {
          feed.css({
            "height": (options.height * 24) + "px",
            "overflow": "auto"
          });
        } else {
          feed.css("height", "auto");
        }
        
        if (maxItems() && complete.is(':hidden')) {
          complete.show();
        }
      }

      function itemIllumination(text, etext) {
        if (options.filter_case) {
          try {
            var regex = new RegExp("(.*)(" + etext + ")(.*)", ((options.filter_case) ?"g":"gi"));
            var text = text.replace(regex,'$1<em>$2</em>$3');
          } catch(ex) {};
        } else {
          try {
            var regex = new RegExp("(.*)(" + etext.toLowerCase() + ")(.*)", "gi");
            var text = text.replace(regex,'$1<em>$2</em>$3');
          } catch(ex) {};
        }
        return text;
      }

      function bindFeedEvent() {
        feed.children("li").mouseover( function() {
          feed.children("li").removeClass("auto-focus");
          focuson = $(this);
          focuson.addClass("auto-focus");
        });
        feed.children("li").mouseout( function() {
          $(this).removeClass("auto-focus");
          focuson = null;
        });
      }

      function removeFeedEvent() {
        feed.unbind("mouseover").unbind("mouseout").mousemove( function() {
          bindFeedEvent();
          feed.unbind("mousemove");
        });
      }

      function bindEvents() {
        var maininput = $("#" + elemid + "_annoninput").children(".maininput");
        bindFeedEvent();
        
        feed.children("li").unbind("mousedown").mousedown( function() {
          var option = $(this);
          addItem(option.text(), option.attr("rel"), 0, 0, 1);
          feed.hide();
          complete.hide();
        });
        
        maininput.unbind("keydown");
        maininput.keydown( function(event) {
          
          if (event.keyCode != _key.backspace) {
            holder.children("li.bit-box.deleted").removeClass("deleted");
          }

          if ((event.keyCode == _key.enter || event.keyCode == _key.tab) && checkFocusOn()) {
            var option = focuson;
            addItem(option.text(), option.attr("rel"), 0, 0, 1);
            return _preventDefault(event);
          }

          if ((event.keyCode == _key.enter || event.keyCode == _key.tab) && !checkFocusOn()) {
            if (options.newel) {
              var value = xssPrevent($(this).val());
              addItem(value, value, 0, 0, 1);
              return _preventDefault(event);
            }
            if (options.addontab && options.newel) {
              focuson = feed.children("li:visible:first");
              var option = focuson;
              addItem(option.text(), option.attr("rel"), 0, 0, 1);
              return _preventDefault(event);
            }
          }

          if (event.keyCode == _key.downarrow) {
            nextItem('first');
          }          
          if (event.keyCode == _key.uparrow) {
            nextItem('last');
          }
        });
      }
      
      function nextItem(position) {
        removeFeedEvent();
        if (focuson == null || focuson.length == 0) {
          focuson = feed.children("li:visible:" + position);
          feed.get(0).scrollTop = position == 'first' ? 0 : parseInt(focuson.get(0).scrollHeight, 10) * (parseInt(feed.children("li:visible").length, 10) - Math.round(options.height / 2));
        } else {
          focuson.removeClass("auto-focus");
          focuson = position == 'first' ? focuson.nextAll("li:visible:first") : focuson.prevAll("li:visible:first");
          var prev = parseInt(focuson.prevAll("li:visible").length, 10);
          var next = parseInt(focuson.nextAll("li:visible").length, 10);
          if (((position == 'first' ? prev : next) > Math.round(options.height / 2) || (position == 'first' ? prev : next) <= Math.round(options.height / 2)) && typeof(focuson.get(0)) != "undefined") {
            feed.get(0).scrollTop = parseInt(focuson.get(0).scrollHeight, 10) * (prev - Math.round(options.height / 2));
          }
        }
        feed.children("li").removeClass("auto-focus");
        focuson.addClass("auto-focus");
      }
      
      function _preventDefault(event) {
        complete.hide();
        event.preventDefault();
        focuson = null;
        return false;
      }

      function maxItems() {
          return options.maxitems != 0 && (holder.children("li.bit-box").length < options.maxitems);
      }

      function addTextItem(value) {
        if (options.newel && maxItems()) {
          feed.children("li[fckb=1]").remove();
          if (value.length == 0) {
            return;
          }
          var li = $('<li rel="'+value+'" fckb="1"">').html(xssDisplay(value));
          feed.prepend(li);
          counter++;
        }
        return;
      }

      function funCall(func, item) {
        var _object = {};
        for (i = 0; i < item.get(0).attributes.length; i++) {
          if (item.get(0).attributes[i].nodeValue != null) {
            _object["_" + item.get(0).attributes[i].nodeName] = item.get(0).attributes[i].nodeValue;
          }
        }
        return func.call(func, _object);
      }

      function checkFocusOn() {
        if (focuson == null || focuson.length == 0) {
          return false;
        }
        return true;
      }
      
      function xssPrevent(string, flag) {
        if (typeof flag != "undefined") {
          for(i = 0; i < string.length; i++) {
            var charcode = string.charCodeAt(i);
            if ((_key.exclamation <= charcode && charcode <= _key.slash) || 
                (_key.colon <= charcode && charcode <= _key.at) || 
                (_key.squarebricket_left <= charcode && charcode <= _key.apostrof)) {
              string = string.replace(string[i], escape(string[i]));
            }
          }
          string = string.replace(/(\{|\}|\*)/i, "\\$1");
        }
        return string.replace(/script(.*)/g, "");
      }
      
      function xssDisplay(string, flag) {
        string = string.replace('\\', "");
        if (typeof flag != "undefined") {
          return string;
        }
        return unescape(string);
      }

      var options = $.extend({
        json_url: null,
        cache: false,
        height: "10",
        newel: false,
        addontab: false,
        firstselected: false,
        filter_case: false,
        filter_selected: false,
        complete_text: "Start to type...",
        maxshownitems: 30,
        maxitems: 10,
        onselect: null,
        onremove: null,
        attachto: null,
        delay: 350,
        bricket: true
      },
      opt);

      //system variables
      var holder = null;
      var feed = null;
      var complete = null;
      var counter = 0;
      
      var focuson = null;
      var deleting = 0;
      var complete_hover = 1;

      var element = $(this);
      var elemid = element.attr("id");
      
      var json_cache = $('<div></div>').after(element);
      var json_cache_object = {
        'set': function (id, val) {
          json_cache.data(id, val);
        },
        'get': function(id) {
          return json_cache.data(id);
        }
      };
      
      var _key = { 'enter': 13,
                   'tab': 9,
                   'backspace': 8,
                   'leftarrow': 37,
                   'uparrow': 38,
                   'rightarrow': 39,
                   'downarrow': 40,
                   'exclamation': 33,
                   'slash': 47,
                   'colon': 58,
                   'at': 64,
                   'squarebricket_left': 91,
                   'apostrof': 96
                 };
      
      var randomId = function() {
        var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
        var randomstring = '';
        for (var i = 0; i < 32; i++) {
            var rnum = Math.floor(Math.random() * chars.length);
            randomstring += chars.substring(rnum, rnum + 1);
        }
        return randomstring;
      };
      
      var cache = {
        'search': function (text, callback) {
          var temp = new Array();
          var regex = new RegExp(text, (options.filter_case ? "g": "gi"));
          $.each(element.data(), function (i, _elem) {
            if (typeof _elem.search === 'function') {
              if (_elem.search(regex) != -1) {
                temp.push({'key': i, 'value': _elem});
              }
            }
          });
          return temp;
        },
        'set': function (id, val) {
          element.data(id, val);
        },
        'get': function(id) {
          return element.data(id);
        },
        'clear': function() {
          element.removeData();
        },
        'length': function() {
          var count = 0;
          for (var k in this) {
            if (this.hasOwnProperty(k)) {
              ++count;
            }
          }
          return count;
        }
      };
      
      init();
      return this;
    });
  };
})(jQuery);