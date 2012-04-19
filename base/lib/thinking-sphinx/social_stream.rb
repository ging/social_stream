require 'social_stream/base/thinking-sphinx'

ThinkingSphinx::Index::Builder.send :include, SocialStream::Base::ThinkingSphinx::Index::Builder
