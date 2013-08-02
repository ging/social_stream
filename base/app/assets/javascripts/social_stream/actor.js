SocialStream.Actor = (function(SS, $, undefined) {
  // Select2
  var select2 = function(selector) {
    $(selector).select2({
      multiple: true,
      minimumInputLength: 1,
      ajax: {
        url: $(selector).attr('data-path'),
        dataType: 'json',
        data: function(term, page) {
          return { q: term, page: page, type: $(selector).attr('data-type') };
        },
        results: function(data, page) {
          return { results: data };
        }
      },
      id: function(object) { return object.id.toString(); },
      formatResult: select2FormatResult,
      formatSelection: select2FormatSelection
    });
  };

  var select2FormatSelection = function(object, container, query) {
    return object.name;
  };

  var select2FormatResult = function(object, container) {
    return '<img src="' + object.image.url + '"> ' + object.name;
  };

  return {
    select2: select2
  };
  
})(SocialStream, jQuery);
