# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "midwife/version"

Gem::Specification.new do |s|
  s.name        = "midwife"
  s.version     = Midwife::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Li-Hsuan Lung"]
  s.email       = ["lihsuan@8thlight.com"]
  s.homepage    = "http://github.com/naush/midwife"
  s.summary     = %q{A collection of preprocessors for frontend development}
  s.description = %q{}

  s.add_dependency "rake", "0.9.2.2"
  s.add_dependency "listen", "0.5.3"
  s.add_dependency "rb-fsevent", "~> 0.9.1"
  s.add_dependency "haml", "3.1.7"
  s.add_dependency "sass", "3.2.1"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
