//= require social_stream/pagination

SocialStream.Timeline = (function(SS, $, undefined){
  // FIXME: DRY!!
  var showCallbacks = [];
  var createCallbacks = [];

  var addShowCallback = function(callback){
    showCallbacks.push(callback);
  };

  var addCreateCallback = function(callback){
    createCallbacks.push(callback);
  };

  var show = function(){
    $.each(showCallbacks, function(i, callback){ callback(); });
  };

  var init = function() {
    console.log("SocialStream.Timeline.init() is deprecated. Please, use SocialStream.Timeline.show()");
    show();
  };

  var create = function(activityId){
    $.each(createCallbacks, function(i, callback){ callback(activityId); });
  };

  var initPrivacyTooltips = function(activityId) {
    var summaryId = '.audience';
    var fullId = '.audience-tooltip';

    if (activityId !== undefined) {
      fullId = '#' + activityId + ' ' + fullId;
      summaryId = '#' + activityId + ' ' + summaryId;
    }

    $(fullId).hide();
    $(summaryId).tooltip({
      html: true,
      trigger: 'click hover',
      title: function(){
        return $(this).siblings(fullId).html();
      }
    });
  };

  var initComments = function(){
    //if there are 4 or more commments we only show the last 2 and a link to show the rest
    $(".timeline .comments").each(function(){
      var comments = $(this).children(".child");

      //check if there are more than 3 comments
      if (comments.size() > 3){
        $(this).prepend("<div class='hidden_comments'><a href='#' onclick='SocialStream.Timeline.showAllComments(\"" + 
                        $(this).attr('id') +"\"); return false;'>" + I18n.t('comment.view_all') + " (" +
                        comments.size() + ")</a></div>");

        comments.slice(0, comments.size() - 2).hide();
      }
    });

  };

  var showAllComments = function(id){
    $("#"+id).children().show('show');
    //and hide the hide_show_comments
    $("#"+id).children(".hidden_comments").hide();
  };

  var resetWallInput = function(){
    $('#post_text').val('');
  };

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
    SS.Pagination.show(show);
  };

  addShowCallback(initPrivacyTooltips);
  addShowCallback(initComments);
  addShowCallback(initModalCarousel);
  addShowCallback(initPagination);

  addCreateCallback(initPrivacyTooltips);
  addCreateCallback(resetWallInput);

  return {
    init: init,
    addCreateCallback: addCreateCallback,
    addInitCallback: addShowCallback,
    addShowCallback: addShowCallback,
    create: create,
    initPrivacyTooltips: initPrivacyTooltips,
    showAllComments: showAllComments,
    show: show
  };
}) (SocialStream, jQuery);
