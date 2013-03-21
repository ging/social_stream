/* TODO API:
 * SS.Callbacks.define(this, [ 'index', 'update' ]);
 *
 * callback('index', initList);
 * callback('update', resetNameForm);
 *
 * return returnCallbacksAnd({});
 */
SocialStream.Callbacks = (function(SS, $, undefined) {
  var callback = function(type, func) {
    console.log(callbacks);
    callbacks[type].push(func);
  };

  var returnCallbacksAnd = function(obj) {
    var r = {};

    $.each(this.callbacks, function(key) {
      r[key] = this[key];
    });

    return $.extend(r, obj);
  };

  var define = function(f, callbacks) {
    console.log(f);
    f.callbacks = {};

    $.each(f.callbacks, function(i, c) {
      f.callbacks[c] = [];

      f[c] = function(options) {
        console.log(c);
        $.each(this.callbacks[c], function(i, func){ func(options); });
      };
    });

    f.callback = callback;
  };

  return {
    define: define
  };
})(SocialStream, jQuery);
