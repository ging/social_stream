class SocialStream::InstallGenerator < Rails::Generators::Base #:nodoc:
  hook_for :base
  hook_for :documents
  hook_for :events
  hook_for :linkser
end
