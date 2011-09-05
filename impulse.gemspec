# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "impulse/version"

Gem::Specification.new do |s|
  s.name        = "impulse"
  s.version     = Impulse::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lloyd Pick"]
  s.email       = ["lloyd.pick+impulse@forward.co.uk"]
  s.homepage    = "https://github.com/forward/impulse"
  s.summary     = %q{RubyGem to help make very quick RRDTool graphs}
  s.description = %q{Ability to make RRDTool graphs with zero thought}

  s.rubyforge_project = "impulse"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency(%q<rake>)
end
