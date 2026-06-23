# frozen_string_literal: true
require_relative "lib/global_id/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'globalid'
  s.version     = GlobalID::VERSION
  s.summary     = 'Refer to any model with a URI: gid://app/class/id'
  s.description = 'URIs for your models makes it easy to pass references around.'

  s.required_ruby_version = '>= 2.7.0'

  s.license = 'MIT'

  s.author   = 'David Heinemeier Hansson'
  s.email    = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.files        = Dir['MIT-LICENSE', 'README.md', 'lib/**/*']
  s.require_path = 'lib'

  s.add_runtime_dependency 'activesupport', '>= 6.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest', '< 6'

  s.metadata = {
    "bug_tracker_uri"       => "https://github.com/rails/globalid/issues",
    "changelog_uri"         => "https://github.com/rails/globalid/releases/tag/v#{GlobalID::VERSION}",
    "mailing_list_uri"      => "https://discuss.rubyonrails.org/c/rubyonrails-talk",
    "source_code_uri"       => "https://github.com/rails/globalid/tree/v#{GlobalID::VERSION}",
    "rubygems_mfa_required" => "true",
  }
end
