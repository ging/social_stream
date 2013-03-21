SocialStream.Action = (function(SS, $, undefined){
	var updateCallbacks = [];

	var addUpdateCallback = function(callback){
		updateCallbacks.push(callback);
	}

	var update = function(action){
		$.each(updateCallbacks, function(i, callback){ callback(action); });
	}

        var updateFollow = function(action){
          var follow = action.follow;

          if (!follow) {
            return;
          }

          followForms(action).replaceWith(follow.form);
          followSentences(action).replaceWith(follow.sentence);
        }

	var followForms = function(action) {
		return $('.follow_form-' + action.activity_object.id);
	}

	var followSentences = function(action) {
		return $('.follow_sentence-' + action.activity_object.id);
	}

        addUpdateCallback(updateFollow);

	return {
		addUpdateCallback: addUpdateCallback,
		update: update,
		followForms: followForms,
		followSentences: followSentences
	}

})(SocialStream, jQuery);
