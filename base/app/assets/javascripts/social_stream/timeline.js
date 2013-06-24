//= require social_stream/callback
//= require social_stream/audience
//= require social_stream/comment
//= require social_stream/pagination
//= require social_stream/wall

SocialStream.Timeline = (function(SS, $, undefined){
  var callback = new SS.Callback();

  var initModalCarousel = function() {
    var elements = $('.timeline [data-modal-carousel-id="false"]');

    elements.each(addToModalCarousel);

    elements.click(showModalCarousel);
  };

  var addToModalCarousel = function(i, el) {
    var timeline = $(el).closest('.timeline'),
        carousel = $('#modal-carousel', timeline),
        carouselInner = $('.carousel-inner', carousel),
        carouselIndicators = $('.carousel-indicators', carousel),
        inEl,
        order;

    inEl = $('<div/>', { class: 'item' }).
      append($(el).attr('data-modal-carousel-content')).
      appendTo(carouselInner);

    order = carouselInner.children('div').length - 1;

    if (order === 0) {
      inEl.addClass('active');
    }

    $('<li/>', { "data-target": "#modal-carousel", "data-slide-to" : order }).
      appendTo(carouselIndicators);

    $(el).attr('data-modal-carousel-id', order);
  };

  var showModalCarousel = function(event) {
    var timeline = $(event.target).closest('.timeline');

    $('#modal-carousel', timeline).
      carousel(parseInt($(event.target).attr('data-modal-carousel-id'), 10)).
      carousel('pause');
    $('.timeline-modal-carousel', timeline).modal('show');
  };

  var initPagination = function() {
    SS.Pagination.show(callback.handlers.update);
  };

  callback.register('show',
                    SS.Audience.index,
                    SS.Comment.index,
                    initModalCarousel,
                    initPagination);

  callback.register('create',
                    SS.Audience.index,
                    SS.Comment.index);

  callback.register('update',
                    SS.Audience.index,
                    SS.Comment.index,
                    initModalCarousel);


  return callback.extend({
  });
}) (SocialStream, jQuery);
