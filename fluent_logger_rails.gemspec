# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fluent_logger_rails/version"

Gem::Specification.new do |s|
  s.name        = "fluent_logger_rails"
  s.version     = FluentLoggerRails::VERSION
  s.authors     = ["Waldemar Quevedo"]
  s.email       = ["waldemar.quevedo@gmail.com"]
  s.homepage    = "http://github.com/wallyqs/fluent-logger-rails"
  s.summary     = %q{Gem to swap Rails default logger to use Fluent Ruby plugin }
  s.description = %q{Gem to swap Rails default logger to use Fluent Ruby plugin }

  s.rubyforge_project = "fluent_logger_rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency "fluentd"
  s.add_runtime_dependency "fluent-logger"
  s.add_runtime_dependency "rails", '<= 3.0.9'
end
