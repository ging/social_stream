SocialStream.FullCalendar = (function(SS, $, Scheduler, undefined){
  var current;
  var eventColor = 'black';

  var showCallbacks = [];

  var addShowCallback = function(callback){
    showCallbacks.push(callback);
  };

  var show = function(options){
    $.each(showCallbacks, function(i, callback){ callback(options); });
  };

  var createCallbacks = [];

  var addCreateCallback = function(callback){
    createCallbacks.push(callback);
  };

  var create = function(options){
    $.each(createCallbacks, function(i, callback){ callback(options); });
  };

  var getCurrent = function() {
    return current;
  };

  var getCalendarEl = function() {
    return $('#calendar');
  };

  var getFormEl = function() {
    return $('#calendar_form');
  };

  var initFullCalendar = function() {
    var calendar = getCalendarEl();

    var options = {
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      ignoreTimezone: false,
      firstDay: 1,
      eventColor: eventColor,
      events: getEvents
    };

    if (calendar.attr('data-can-create')) {
      $.extend(options, {
        selectable: true,
        selectHelper: true,
        select: selectEvent
        // Implement event edition
        // editable: true,
      });
    }

    current = calendar.fullCalendar(options);

    // Hack for Fullcalendar + Twitter Bootstrap, see https://github.com/addyosmani/jquery-ui-bootstrap/issues/37
    $('.fc-button-content').each(function() {
      $(this).parent().parent().html($(this).html());
    });

    if (calendar.attr('data-date'))
      // TODO: optimize this to save one index call
      current.fullCalendar('gotoDate', new Date(calendar.attr('data-date') * 1000));

    if (calendar.attr('data-view'))
      current.fullCalendar('changeView', calendar.attr('data-view'));
  };

  var initFormModal = function() {
    getFormEl().modal({
      show: false
    });
  };

  var selectEvent = function(startDate, endDate, allDay, jsEvent){
    var c = getFormEl().find('.new_event');

    c.children('#event_start_at').val(startDate.toJSON());
    c.children('#event_end_at').val(endDate.toJSON());
    c.children('#event_all_day').val(allDay.toString());

    // From rails-scheduler gem
    Scheduler.form.init(c.find('.scheduler_form'), startDate);

    getFormEl().modal('show');
  };

  var getEvents = function(start, end, callback) {
    $.ajax({
      url: getCalendarEl().attr('data-events-path'),
      dataType: 'json',
      data: {
        // our hypothetical feed requires UNIX timestamps
        start: Math.round(start.getTime() / 1000),
        end: Math.round(end.getTime() / 1000)
      },
      success: function(events) {
        callback(
          $.map(events, function(event) {
            event.color = eventColor;
            return event;
          })
        );
      }
    });
  };

  var addEvent = function(options) {
    getFormEl().modal('hide');

    $.each(JSON.parse(options.events), function(i, ev) {
      ev.color = eventColor;
      current.fullCalendar('renderEvent', ev,
                           true // make the event "stick"
                          );
    });

    current.fullCalendar('unselect');
  };

  var resetForm = function() {
    var form = getFormEl();
    form.find('#event_title').val('');
    form.find('#event_description').val('');
    
    Scheduler.form.reset(form.find('.scheduler_form'));
  };

  addShowCallback(initFullCalendar);
  addShowCallback(initFormModal);

  addCreateCallback(addEvent);
  addCreateCallback(resetForm);

  return {
    create: create,
    current: getCurrent,
    getFormEl: getFormEl,
    show: show
  };

})(SocialStream, jQuery, Scheduler);
