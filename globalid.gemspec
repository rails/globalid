Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'globalid'
  s.version     = '0.4.0'
  s.summary     = 'Refer to any model with a URI: gid://app/class/id'
  s.description = 'URIs for your models makes it easy to pass references around.'

  s.required_ruby_version = '>= 1.9.3'

  s.license = 'MIT'

  s.author   = 'David Heinemeier Hansson'
  s.email    = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.files        = Dir['MIT-LICENSE', 'README.md', 'lib/**/*']
  s.require_path = 'lib'

  s.add_runtime_dependency 'activesupport', '>= 4.2.0'

  s.add_development_dependency 'rake'
end
