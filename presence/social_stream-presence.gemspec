# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "social_stream/presence/version"

Gem::Specification.new do |s|
  s.name        = "social_stream-presence"
  s.version     = SocialStream::Presence::VERSION
  s.authors     = ["Aldo Gordillo"]
  s.email       = ["agordillos@gmail.com"]
  s.homepage    = "https://github.com/ging/social_stream/wiki/Getting-Started-With-Social-Stream-Presence"
  s.summary = "Presence capabilities for Social Stream, the core for building social network websites."
  s.description = "Social Stream Presence provides everything you need for including presence, instant messaging and video chat services in your social network website, including a complete chat fully integrated with Social Stream."

  s.rubyforge_project = "social_stream-presence"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # Gem dependencies
  s.add_runtime_dependency('social_stream-base', '~> 0.22.0')
  
  s.add_runtime_dependency "xmpp4r"

  s.add_runtime_dependency "net-ssh"

  s.add_runtime_dependency "net-sftp"
  
  s.add_development_dependency "debugger"
  
end
