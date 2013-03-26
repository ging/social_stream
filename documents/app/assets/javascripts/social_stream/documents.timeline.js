//= require social_stream/timeline
//= require social_stream/audio
//= require social_stream/video

SocialStream.Timeline.callbackRegister('show',
                                       SocialStream.Audio.show,
                                       SocialStream.Video.show);
