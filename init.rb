require 'social_stream'

SocialStream::Rails::Common.inflections

AssetBundler.paths += Array(File.join(File.dirname(__FILE__), 'app', 'assets'))
