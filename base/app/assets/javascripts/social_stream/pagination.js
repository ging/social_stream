SocialStream.Pagination = (function(SS, $, undefined){

  var show = function(callback) {
    var nav = $('nav.more');

    $('a', nav).each(function(i, btn) {
      $(btn).attr('data-page', "2");
    });

    $('.loading', nav).hide();

    $('a', nav).click(function(event) {
      event.preventDefault();

      $(event.target).hide();
      $(event.target).closest('nav.more').find('.loading').show();

      $.ajax({
        url: $(this).attr('data-path'),
        dataType: 'html',
        data: { page: $(this).attr('data-page') },
        type: 'GET',
        success: function(data) {
          var nav = $(event.target).closest("nav.more"),
              per_page = parseInt($(event.target).attr('data-per_page'), 10),
              remaining = parseInt($(event.target).attr('data-remaining'), 10) - per_page;

          nav.before(data);
          nav.find('.loading').hide();

          // data.length is equal to 1
          if (remaining > 0) {
            $(event.target).attr('data-remaining', remaining);
            $(event.target).attr('data-page', parseInt($(event.target).attr('data-page'), 10) + 1);
            $(event.target).html(I18n.t('layout.more', { count: remaining }));
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
