require 'lib/generators/social_stream/templates/migration'
CreateSocialStream.up

require File.expand_path("../../dummy/db/seeds", __FILE__)
