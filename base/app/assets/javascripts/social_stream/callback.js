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
  var register = function() {
    var callback = this,
        funcs    = Array.prototype.slice.call(arguments),
        name     = funcs.shift();

    if (this.registry[name] === undefined) {
      this.registry[name] = [];

      this.handlers[name] = function(options) {
        $.each(callback.registry[name], function(i, f) {
          f(options);
        });
      };
    }

    this.registry[name].push.apply(this.registry[name], funcs);
  };

  var extend = function(obj) {
    var callback = this;

    // Create current handlers
    for (var c in callback.handlers) {
      if (callback.handlers.hasOwnProperty(c)) {
        obj[c] = callback.handlers[c];
      }
    }

    obj.callbackRegister = function() {
      var args = Array.prototype.slice.call(arguments),
          name = args.shift();

      callback.register.apply(callback, arguments);

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
