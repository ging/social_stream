//= require jquery.inview

SocialStream.Pagination = (function(SS, $, undefined){

  var show = function(callback) {
    $(".btn-see-more").each(function(i, btn) {
      $(btn).attr('data-page', "2");
      $(btn).closest('nav.more').find('.loading').hide();
    });

    $(".btn-see-more").bind('inview', function(event, isInview) {
      if (isInview) {
        $(this).click();
      }
    });

    $(".btn-see-more").click(function(event) {
      event.preventDefault();

      $(event.target).hide();
      $(event.target).closest('nav.more').find('.loading').show();

      $.ajax({
        url: $(this).attr('data-path'),
        dataType: 'html',
        data: { page: $(this).attr('data-page') },
        type: 'GET',
        success: function(data) {
          var nav = $(event.target).closest("nav.more");

          nav.before(data);
          nav.find('.loading').hide();

          // data.length is equal to 1
          if (data.length > 1) {
            $(event.target).attr('data-page', parseInt($(event.target).attr('data-page'), 10) + 1);
            $(event.target).show();
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
