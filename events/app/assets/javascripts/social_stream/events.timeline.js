//= require social_stream/timeline
//= require social_stream/event

SocialStream.Timeline.callbackRegister('show', SocialStream.Event.index);

SocialStream.Timeline.callbackRegister('update', SocialStream.Event.index);
