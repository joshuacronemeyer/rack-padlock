$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rack/padlock/version'
Gem::Specification.new do |s|
  s.name         = 'rack-padlock'
  s.version      = Rack::Padlock::VERSION
  s.summary      = "A Toolkit for writing tests that ensure all traffic on a page is secure."
  s.description  = "A Gem for testing web applications don't generate mixed secure/insecure traffic. Keep that browser padlock locked!"
  s.author       = "Josh Cronemeyer"
  s.email        = 'joshuacronemeyer@gmail.com'
  s.homepage     = 'https://github.com/joshuacronemeyer/rack-padlock'
  s.files        = Dir.glob("{lib}/**/*") + %w[README.md]
  s.require_path = 'lib'
  s.test_files   = Dir.glob("{test}/**/*")
  s.add_dependency('rack')
  s.add_development_dependency("bundler")
  s.add_development_dependency("rake")
  s.add_development_dependency("minitest")
  s.add_development_dependency("rack-test")
end