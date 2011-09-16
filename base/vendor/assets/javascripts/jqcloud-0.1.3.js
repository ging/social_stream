/*!
 * jQCloud Plugin for jQuery
 *
 * Version 0.1.3
 *
 * Copyright 2011, Luca Ongaro
 * Licensed under the MIT license.
 *
 * Date: Wed Feb 16 11:41:32 2011 +0100
 */
(function( $ ){
  $.fn.jQCloud = function(word_array, callback_function) {
    // Reference to the container element
    var $this = this;

    var drawWordCloud = function() {
      // Helper function to test if an element overlaps others
      var hitTest = function(elem, other_elems){
        // Pairwise overlap detection
        var overlapping = function(a, b){
          if (Math.abs(2.0*a.offsetLeft + a.offsetWidth - 2.0*b.offsetLeft - b.offsetWidth) < a.offsetWidth + b.offsetWidth) {
            if (Math.abs(2.0*a.offsetTop + a.offsetHeight - 2.0*b.offsetTop - b.offsetHeight) < a.offsetHeight + b.offsetHeight) {
              return true;
            }
          }
          return false;
        };
        var i = 0;
        // Check elements for overlap one by one, stop and return false as soon as an overlap is found
        for(i = 0; i < other_elems.length; i++) {
          if (overlapping(elem, other_elems[i])) {
            return true;
          }
        }
        return false;
      };

      // Sort word_array from the word with the highest weight to the one with the lowest
      word_array.sort(function(a, b) { if (a.weight < b.weight) {return 1;} else if (a.weight > b.weight) {return -1;} else {return 0;} });

      var step = 2.0;
      var already_placed_words = [];
      var aspect_ratio = $this.width() / $this.height();
      var origin_x = $this.width() / 2.0;
      var origin_y = $this.height() / 2.0;

      // Move each word in spiral until it finds a suitable empty place
      $.each(word_array, function(index, word) {
        var angle = 6.28 * Math.random();
        var radius = 0.0;
        // Linearly map the original weight to a discrete scale from 1 to 10
        var weight = Math.round((word.weight - word_array[word_array.length - 1].weight)/(word_array[0].weight - word_array[word_array.length - 1].weight) * 9.0) + 1;

        var inner_html = word.url !== undefined ? "<a href='" + word.url + "'>" + word.text + "</a></span>" : word.text;
        $this.append("<span id='word_" + index + "' class='w" + weight + "' title='" + (word.title || "") + "'>" + inner_html + "</span>");

        var width = $("#word_" + index).width();
        var height = $("#word_" + index).height();
        var left = origin_x - width / 2.0;
        var top = origin_y - height / 2.0;
        $('#word_'+index).css("position", "absolute");
        $('#word_'+index).css("left", left + "px");
        $('#word_'+index).css("top", top + "px");

        while(hitTest(document.getElementById("word_"+index), already_placed_words)) {
          radius += step;
          angle += (index % 2 === 0 ? 1 : -1)*step;

          left = origin_x + (radius*Math.cos(angle) - (width / 2.0)) * aspect_ratio;
          top = origin_y + radius*Math.sin(angle) - (height / 2.0);

          $('#word_' + index).css('left', left + "px");
          $('#word_' + index).css('top', top + "px");
        }
        already_placed_words.push(document.getElementById("word_"+index));
      });

      if (typeof callback_function === 'function') {
        callback_function.call(this);
      }
    };

    // Delay execution so that the browser can render the page before the computatively intensive word cloud drawing
    setTimeout(function(){drawWordCloud();}, 100);
    return this;
  };
})(jQuery);