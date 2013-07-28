# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paradeiser/version'

Gem::Specification.new do |spec|
  spec.name          = "paradeiser"
  spec.version       = Paradeiser::VERSION
  spec.authors       = ["Nicholas E. Rabenau"]
  spec.email         = ["nerab@gmx.net"]
  spec.description   = %q{Paradeiser is a command-line tool for the Pomodoro Technique. It keeps track of the current pomodoro and assists the user in managing active and past pomodori as well as breaks. Status commands and reports are provided to get insights.}
  spec.summary       = %q{Command-line tool for the Pomodoro Technique}
  spec.homepage      = "https://github.com/nerab/paradeiser"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'commander'
  spec.add_runtime_dependency 'require_all'
  spec.add_runtime_dependency 'state_machine'

  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'growl'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'ruby-graphviz'
end
