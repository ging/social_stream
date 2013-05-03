//= require select2

SocialStream.Tag = (function(SS, $, undefined) {
  // Select2
  var select2 = function(selector) {
    $(selector).select2({
      multiple: true,
      ajax: {
        url: $(selector).attr('data-path'),
        dataType: 'json',
        data: function(term, page) {
          return {
            q: term,
            page: page
          };
        },
        results: select2Results
      },
      initSelection: select2InitSelection
    });
  };

  var select2Results = function(data, page) {
    return {
      results: data.map(function(el) {
        return {
          id: el.name,
          text: el.name
        };
      })
    };
  };

  var select2InitSelection = function(element, callback) {
    var selection = $(element).val().split(", ").map(function(el) {
      return { id: el, text: el };
    });

    callback(selection);
  };

  return {
    select2: select2
  };
})(SocialStream, jQuery);
