SocialStream.RelationCustom = (function(SS, $, undefined){
	// FIXME: DRY!!
	var indexCallbacks = [];

	var addIndexCallback = function(callback){
		indexCallbacks.push(callback);
	};

	var index = function(){
		$.each(indexCallbacks, function(i, callback){ callback(); });
	};

	var createCallbacks = [];

	var addCreateCallback = function(callback){
		createCallbacks.push(callback);
	};

	var create = function(options){
		$.each(createCallbacks, function(i, callback){ callback(options); });
	};

	var updateCallbacks = [];

	var addUpdateCallback = function(callback){
		updateCallbacks.push(callback);
	};

	var update = function(options){
		$.each(updateCallbacks, function(i, callback){ callback(options); });
	};

  var getListEl = function() {
    return $('#relation_customs .relation_list');
  };

  var getPermissionsPath = function() {
    return getListEl().attr('data-permissions_path');
  };

  var initList = function(el) {
    var list = getListEl();
    var scope = el ? el : list;
    
    list.find('.edit_name').hide();
    list.find('.new_relation_custom').hide();
    list.find('.actions').hide();

    scope.find('input[type=radio]').click(function() {
      hideEditForms();

      list.find('.actions').hide();
      $(this).closest('.relation_custom').find('.actions').show();
      loadPermissionList(this);
    });

    scope.find('.actions .edit').click(function() {
      showEditForm($(this).closest('.relation_custom'));
    });

    scope.find('.edit_name .submit').click(function() {
      $(this).closest('.edit_name').find('form').submit();
    });

    scope.find('a.new').click(function(e) {
      e.preventDefault();
      $(this).closest('#new_relation').find('.new_relation_custom').toggle('slow');
    });
  };

  var showEditForm = function(el) {
    el.find('label').hide('slow');
    el.find('.actions').hide('slow');

    el.find('.edit_name').show('slow');

    $('html').on('click.social_stream.relation_custom.edit_name', editFormsListener);
  };

  var editFormsListener = function(event) {
    if (event && $(event.srcElement).closest('.relation_custom').length > 0) {
      return;
    }

    hideEditForms();

    $('html').off('click.social_stream.relation_custom.edit_name');
  };

  var hideEditForms = function() {
    $('.edit_name:visible').each(function() {
      $(this).hide('slow');

      var parent = $(this).closest('.relation_custom');
      parent.find('label').show('slow');
      parent.find('.actions').show('slow');
    });
  };

  var loadPermissionList = function(el) {
    var radioInput = $(el);
    var relVal = radioInput.val();

    $('#permissions').find('.relation_permissions').hide();

    if (radioInput.attr('data-loaded')) {
      console.log('#relation_' + relVal + '_permissions');
      $('#relation_' + relVal + '_permissions').show();

      return;
    }

    var formEl = $('<div/>', {
      id: 'relation_' + relVal + '_permissions',
      'class': 'relation_permissions'
    });

    formEl.append('<div/>', {
      'class': 'loading'
    });

    formEl.appendTo('#permissions');

   $.get(
     getPermissionsPath(),
     { relation_id: relVal },
     function(html) {
       formEl.html(html);
       radioInput.attr('data-loaded', 'true');

       SS.Permission.initForm(formEl);
     },
    'html');
  };

  var addToList = function(options) {
    var list = getListEl();

    $('#new_relation').before(options.relation.html);

    initList($('#relation_custom_' + options.relation.id));

    resetNewForm();
  };

  var resetNameForm = function(options) {
    if (options.section !== 'edit_name')
      return;

    var el = $('#relation_custom_' + options.relation.id);

    el.find('label').text(options.relation.name);
    el.find('input[name="relation_custom[name]"]').val(options.relation.name);

    hideEditForms();
  };

  var resetNewForm = function() {
    var el = $('#new_relation');

    el.find('.new_relation_custom').hide();

    el.find('input[name="relation_custom[name]"]').val('');
  };

  addIndexCallback(initList);

  addCreateCallback(addToList);

  addUpdateCallback(resetNameForm);

  return {
    index: index,
    create: create,
    update: update
  };

})(SocialStream, jQuery);
