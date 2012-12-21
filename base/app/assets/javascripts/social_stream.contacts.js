// require jquery.ba-url
// require ajax.paginate

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
      'button': 'btn btn-small',
      'text': relationSelectText
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
    if (options.length === 0) {
      return I18n.t('contact.new.button.zero');
    }
    else {
      return I18n.t('contact.new.button', { count: options.length });
    }

  };

  var sendContactForms = function() {
    $('form.edit_contact[data-status="changed"]').each(function(i, el) {
      var contact = $(el).closest('div.contact');
      var contactId = $(contact).attr('data-contact_id');

      var contacts = $('[data-contact_id="' + contactId + '"]');
      /*
      contacts.each(function(i, el) {
        if ($(el).children('.loading').length === 0)
          $(el).append('<div class="loading"></div>');
      });

      $('[data-contact_id="' + contactId + '"] .loading').show();
      */

      $('button', contacts).data('resetText', relationSelectText($('option:selected', el)) + ' <b class="caret"></b>');
      $('button', contacts).attr('data-loading-text', I18n.t('contact.saving'));
      $('button', contacts).button('loading');
      $('form.edit_contact', contact).submit();
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

  addIndexCallback(initTabs);
  addIndexCallback(initContactButtons);

  addUpdateCallback(updateForm);
  addUpdateCallback(clearLoading);

  // FIXME There is probably a more efficient way to do this..
  $(function() {
    initContactButtons();
    initContactFormsHtmlListener();
  });

  return {
    index: index,
    show: show,
    update: update
  };
})(jQuery, SocialStream);
