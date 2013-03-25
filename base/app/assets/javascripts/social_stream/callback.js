/* API:
 *
 * SS.Foo = (function(SS) {
 *   var callback = new SS.Callback();
 *
 *   var bar = function(options) {
 *   };
 *
 *   callback.register('index', bar);
 *
 *   return callback.extend({});
 * })();
 *
 * SS.Foo.callbackRegister('show', function() {});
 */
SocialStream.Callback = function() {
  this.registry = {};
  this.handlers = {};
};

SocialStream.Callback.prototype = (function(SS, $, undefined) {
  var register = function(name, func) {
    var callback = this;

    if (this.registry[name] === undefined) {
      this.registry[name] = [];

      this.handlers[name] = function(options) {
        $.each(callback.registry[name], function(i, func) {
          func(options);
        });
      };
    }

    this.registry[name].push(func);
  };

  var extend = function(obj) {
    var callback = this;

    // Create current handlers
    for (var c in callback.handlers) {
      if (callback.handlers.hasOwnProperty(c)) {
        obj[c] = callback.handlers[c];
      }
    }

    obj.callbackRegister = function(name, func) {
      callback.register(name, func);

      // Add future handlers
      if (this[name] === undefined) {
        this[name] = callback.handlers[name];
      }
    };

    return obj;
  };

  return {
    extend: extend,
    register: register
  };
})(SocialStream, jQuery);
