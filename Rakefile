require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList.new('test/cases/**/*_test.rb') do |fl|
    fl.exclude('test/cases/pattern_matching_test.rb') if RUBY_VERSION < '2.7'
  end
  t.verbose = true
  t.warning = true
end
