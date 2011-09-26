require File.expand_path('../lib/social_stream/release', __FILE__)

# SocialStream release tasks
class SocialStream < Thor

  desc "release", "release SocialStream's gems"
  def release(*args)
    ::SocialStream::Release.create *args
  end
end
