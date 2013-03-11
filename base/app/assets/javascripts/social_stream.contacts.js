// require jquery.ba-url

SocialStream.Contact = (function($, SS, undefined) {
  var indexCallbacks = [];

  var addIndexCallback = function(callback){
    indexCallbacks.push(callback);
  };

  var index = function(){
    $.each(indexCallbacks, function(i, callback){ callback(); });
  };

  var showCallbacks = [];

  var addShowCallback = function(callback){
    showCallbacks.push(callback);
  };

  var show = function(){
    $.each(showCallbacks, function(i, callback){ callback(); });
  };

  var updateCallbacks = [];

  var addUpdateCallback = function(callback){
    updateCallbacks.push(callback);
  };

  var update = function(options){
    $.each(updateCallbacks, function(i, callback){ callback(options); });
  };

  var initTabs = function() {
    $('.contacts ul.nav-tabs a').click(function() {
      if ($(this).attr('data-loaded'))
        return;

      $.ajax({
        url: $(this).attr('data-path'),
        data: { d: $(this).attr('href').replace('#', '') },
        dataType: 'script',
        type: 'GET'
      });
    });
  };

  var initContactButtons = function() {
    $('.edit_contact select[name*="relation_ids"]').multiselect({
      buttonClass: 'btn btn-small',
      buttonText: relationSelectText
    });

    // Forms
    $('form.edit_contact').each(function(i, el) {
      storeContactFormValues(el);
    });

    $('form.edit_contact ul.dropdown-menu input[type="checkbox"]').change(function() {
      evalFormStatus(this);
    });

    $('form.edit_contact button.dropdown-toggle').on('click.dropdown.data-api', sendContactForms);
  };

  var relationSelectText = function(options) {
    var msg;

    if (options.length === 0) {
      msg = I18n.t('contact.new.button.zero');
    }
    else {
      msg = I18n.t('contact.new.button', { count: options.length });
    }

    return msg + '<b class="caret"></b>';
  };

  var sendContactForms = function() {
    $('form.edit_contact[data-status="changed"]').each(function(i, el) {
      var form = $(el).closest('form.edit_contact');
      var contactId = $(form).attr('data-contact_id');

      var contacts = $('form[data-contact_id="' + contactId + '"]');

      $('button', contacts).data('resetText', relationSelectText($('option:selected', el)));
      $('button', contacts).attr('data-loading-text', I18n.t('contact.saving'));
      $('button', contacts).button('loading');
      form.submit();
    });
  };

  var storeContactFormValues = function(el) {
    $(el).data('relations', getInputValues(el));
  };

  // Dictate if some form has changed its status
  var evalFormStatus = function(el) {
    var form = $(el).closest('form');

    var orig = $(form).data('relations');
    var neww = getInputValues(form);

    if ($(orig).not(neww).length === 0 && $(neww).not(orig).length === 0) {
      $(form).removeAttr('data-status');
    } else {
      $(form).attr('data-status', 'changed');
    }
  };

  // Dictate if some form has changed its status
  var getInputValues = function(form) {
    return $('ul.dropdown-menu input[type="checkbox"]', form).
      map(function() {
      if ($(this).is(':checked'))
        return $(this).val();
    });
  };

  var initContactFormsHtmlListener = function() {
    $('html').on('click.dropdown.data-api', sendContactForms);
  };

  var updateForm = function(options) {
    var form = $('[data-contact_id="' + options.id + '"] form.edit_contact');

    form.removeAttr('data-status');
    storeContactFormValues(form);
  };

  var clearLoading = function(options) {
    var contacts = $('[data-contact_id="' + options.id + '"]');

    //  $('.loading', contacts).hide();

    $('button', contacts).button('reset');
  };

  var replaceContact = function(options) {
    $('[data-contact_id="' + options.id + '"]').each(function(i, el) {
      $.each([ 'suggestions', 'pendings' ], function(i, section) {
        var sectionId = '#' + section;

        if ($(el).closest(sectionId).length > 0) {
          updateTemplate(el, $(sectionId).attr('data-path'));
        }
      });
    });
  };

  var updateTemplate = function(el, path) {
    $.ajax({
      url: path,
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        $(el).fadeOut('slow', function() {
          $(data).replaceAll(el).fadeIn();

          initContactButtons();
        });
      }
    });
  };

  // Select2
  var select2 = function(selector) {
    $(selector).select2({
      multiple: true,
      ajax: {
        url: $(selector).attr('data-path'),
        dataType: 'json',
        data: function(term, page) {
          return { q: term, page: page };
        },
        results: function(data, page) {
          return { results: data };
        }
      },
      id: function(object) { return object.id.toString(); },
      formatResult: select2FormatResult,
      formatSelection: select2FormatSelection,
      initSelection: select2InitSelection
    });
  };

  var select2FormatSelection = function(object, container, query) {
    return object.name;
  };

  var select2FormatResult = function(object, container) {
    return '<img src="' + object.image.url + '"> ' + object.name;
  };

  var select2InitSelection = function(element, callback) {
    callback([ { id: element.val(), name: element.attr('data-recipient-name') } ]);
  };

  addIndexCallback(initTabs);
  addIndexCallback(initContactButtons);

  addUpdateCallback(updateForm);
  addUpdateCallback(clearLoading);
  addUpdateCallback(replaceContact);

  // FIXME There is probably a more efficient way to do this..
  $(function() {
    initContactButtons();
    initContactFormsHtmlListener();
  });

  return {
    index: index,
    show: show,
    update: update,
    select2: select2
  };
})(jQuery, SocialStream);
