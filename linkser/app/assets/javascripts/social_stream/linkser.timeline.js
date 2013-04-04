//= require social_stream/timeline
//= require social_stream/link

SocialStream.Timeline.callbackRegister('show', SocialStream.Link.index);

SocialStream.Timeline.callbackRegister('update', SocialStream.Link.index);
