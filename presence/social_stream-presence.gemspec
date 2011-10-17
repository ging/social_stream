# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "social_stream/presence/version"

Gem::Specification.new do |s|
  s.name        = "social_stream-presence"
  s.version     = Socialstream::Presence::VERSION
  s.authors     = ["Aldo Gordillo"]
  s.email       = ["iamchrono@gmail.com"]
  s.homepage    = "https://github.com/ging/social_stream-presence"
  s.summary = "Presence capabilities for Social Stream, the core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams."

  s.rubyforge_project = "social_stream-presence"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # Gem dependencies
  s.add_runtime_dependency('social_stream-base','~> 0.9.18')
  
  s.add_runtime_dependency "xmpp4r"
  
  s.add_development_dependency "ruby-debug19"
  
end
