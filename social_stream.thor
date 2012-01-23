require File.expand_path('../lib/social_stream/release', __FILE__)

# SocialStream release tasks
class SocialStream < Thor

  desc "create", "update dependencies and release SocialStream's gems"
  def create(*args)
    ::SocialStream::Release.create *args
  end

  desc "release", "release SocialStream's gems"
  def release(*args)
    ::SocialStream::Release.release
  end

  desc "update", "set SocialStream's dependencies"
  def update(*args)
    ::SocialStream::Release.update *args
  end

end
