// require jquery.ba-url
//
//= require social_stream/callback

SocialStream.Contact = (function($, SS, undefined) {
  var callback = new SS.Callback();

  var getForms = function(id) {
    return $('[data-contact_id="' + id + '"]');
  };

  var initTabs = function() {
    $('.contacts ul.nav-tabs a').click(loadTab);
  };

  var loadTab = function() {
    var tab = $(this);

    if (tab.attr('data-loaded'))
      return;

    $.ajax({
      url: tab.attr('data-path'),
      data: {
        type: tab.attr('href').replace('#', ''),
        q: $('#contact-filter').val()
      },
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        $(tab.attr('href')).find('.contact-list').html(data);
        tab.attr('data-loaded', 'true');
        callback.handlers.index();
      }
    });
  };

  var initMultipleButtons = function() {
    $('.edit_contact select[name*="relation_ids"]').multiselect({
      buttonClass: 'btn btn-small',
      buttonText: relationSelectText
    });

    // Forms
    storeFormValues($('form.edit_contact'));

    $('form.edit_contact ul.dropdown-menu input[type="checkbox"]').change(function() {
      evalFormStatus(this);
    });

    $('form.edit_contact button.dropdown-toggle').on('click.dropdown.data-api', saveForms);
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

  var saveForms = function() {
    $('form.edit_contact[data-status="changed"]').each(function(i, form) {
      var contactId = $(form).attr('data-contact_id');
      var contacts = $('form[data-contact_id="' + contactId + '"]');

      $('button', contacts).attr('data-loading-text', I18n.t('contact.saving'));
      $('button', contacts).button('loading');

      if ($('option:selected', form).length > 0) {
        $(form).submit();
      } else {
        if ( confirm(I18n.t('contact.confirm_delete')) ) {
          $(form).submit();
        } else {
          resetForms({ id: contactId });
        }
      }
    });
  };

  var storeFormValues = function(el) {
    $(el).each(function() {
      $(this).data('relations', getInputValues($(this)));
    });
  };

  var restoreFormValues = function(el) {
    var values = $(el).data('relations');
    var select = $('select[name*="relation_ids"]', el);
    
    $('option', select).each(function() {
      $(this).attr('selected', $.inArray($(this).val(), values) >= 0);

    });

    select.multiselect('refresh');
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

  var getInputValues = function(form) {
    return $('ul.dropdown-menu input[type="checkbox"]', form).
      map(function() {
      if ($(this).is(':checked'))
        return $(this).val();
      });
  };

  var setInputValues = function(form) {
    return $('ul.dropdown-menu input[type="checkbox"]', form).
      map(function() {
      if ($(this).is(':checked'))
        return $(this).val();
    });
  };

  var initFilter = function() {
    $('.contact-filter').on('input', filter);
  };
    
  var filter = function() {
    var q = $(this).val();
    var currentTab = $('.contacts .tab-pane.active');

    $('#contacts-loading').show();

    $.ajax({
      data: {
        q: q,
        type: currentTab.attr('id')
      },
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        $('#contacts-loading').hide();
         currentTab.find('.contact-list').html(data);
        callback.handlers.index();
      }
    });
  };

  var hideLoading = function() {
    $('#contacts-loading').hide();
  };

  var initNewGroupModal = function() {
    $('.new_group-modal-link').attr('href', '#new_group-modal');
  };

  var initContactFormsHtmlListener = function() {
    $('html').on('click.dropdown.data-api', saveForms);
  };

  // new_ callbacks
  
  var initHideModal = function() {
    $('#add-contact-modal').on('hide', function () {
      $('input[name="actors"]').select2('close');
      $('select[name="relations[]"]').select2('close');
    });
  };

  var initActorSelect2 = function() {
    SS.Actor.select2('input[name="actors"]');
  };

  var initRelationSelect2 = function() {
    $('select[name="relations[]"]').select2();
  };

  // update callbacks

  var updateForms = function(options) {
    var forms = getForms(options.id);

    storeFormValues(forms);
    $('button', forms).data('resetText', relationSelectText($('option:selected', forms)));
    forms.removeAttr('data-status');
    $('button', forms).button('reset');
  };

  var resetForms = function(options) {
    var forms = getForms(options.id);

    restoreFormValues(forms);
    forms.removeAttr('data-status');
    $('button', forms).data('resetText', relationSelectText($('option:selected', forms)));
    $('button', forms).button('reset');
  };

  // Replace contact in suggestions and pendings
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
    var contact = $(el).closest('.contact');

    $.ajax({
      url: path,
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        $(contact).fadeOut('slow', function() {
          $(data).replaceAll(contact).fadeIn();

          initMultipleButtons();
        });
      }
    });
  };

  var checkAndHideContact = function(options) {
    var forms = getForms(options.id);

    if ($('option:selected', forms).length === 0) {
      forms.closest('.contact').hide('slow');
    }
  };

  var hideContact = function(options) {
    getForms(options.id).closest('.contact').hide('slow');
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

  var initSimpleButtons = function(){
    $(".following-button").mouseenter(function(){
      $(this).hide();
      $(this).siblings(".unfollow-button").show();
    });

    $(".unfollow-button").mouseleave(function(){
      $(this).hide();
      $(this).siblings(".following-button").show();
    });

    $(".unfollow-button").hide();
  };

  callback.register('index',
                    initTabs,
                    initMultipleButtons,
                    initSimpleButtons,
                    initFilter,
                    initNewGroupModal,
                    hideLoading);

  callback.register('new_',
                    initHideModal,
                    initActorSelect2,
                    initRelationSelect2);

  callback.register('update',
                    updateForms,
                    replaceContact,
                    initSimpleButtons,
                    checkAndHideContact);

  callback.register('destroy',
                    initSimpleButtons,
                    hideContact);

  // FIXME There is probably a more efficient way to do this..
  $(function() {
    initMultipleButtons();
    initSimpleButtons();
    initContactFormsHtmlListener();
  });

  return callback.extend({
    select2: select2
  });
})(jQuery, SocialStream);
