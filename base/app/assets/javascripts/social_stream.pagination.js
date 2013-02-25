SocialStream.Pagination = (function(SS, $, undefined){

  var show = function(callback) {
    $(".btn-see-more").each(function(i, btn) {
      $(btn).attr('data-page', "2");
    });

    $(".btn-see-more").click(function(event) {
      event.preventDefault();

      $.ajax({
        url: $(this).attr('data-path'),
        dataType: 'html',
        data: { page: $(this).attr('data-page') },
        type: 'GET',
        success: function(data) {
          $(event.target).before(data);

          // data.length is equal to 1
          if (data.length > 1) {
            $(event.target).attr('data-page', parseInt($(event.target).attr('data-page'), 10) + 1);
          } else {
            $(event.target).hide();
          }

          if (callback) {
            callback();
          }
        }
      });
    });
  };


  return {
    show: show
  };
}) (SocialStream, jQuery);
