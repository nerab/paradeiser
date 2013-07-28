require 'bundler/gem_tasks'
require 'rake/testtask'

require 'paradeiser'
require 'tasks/state_machine'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test' << 'test/helpers'
  test.test_files = FileList['test/**/test_*.rb']
end

task :default => :test
