/******************** Search box js ***********************/
$(document).ready(function() {

  $("#global_search_input").Watermark("Search");

  $("#global_search_input").keyup(function() {
    var searchstring = $(this).val();
    if((searchstring == '')|(searchstring.length<2)) {
      $("#global_search_display").hide();
    } else {
      $.ajax({
        type : "GET",
        url : "search?id=" + searchstring + "&mode=header_search",
        cache : false,
        success : function(html) {
          $("#global_search_display").html(html).show();
        }
      });
    }
    return false;
  });
});

/******************** Search box js END ***********************/