Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'globalid'
  s.version     = '0.2.3'
  s.summary     = 'Refer to any model with a URI: gid://app/class/id'
  s.description = 'URIs for your models makes it easy to pass references around.'

  s.required_ruby_version = '>= 1.9.3'

  s.license = 'MIT'

  s.author   = 'David Heinemeier Hansson'
  s.email    = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.files        = Dir['MIT-LICENSE', 'README.rdoc', 'lib/**/*']
  s.require_path = 'lib'

  # TODO: may relax this dependency further
  s.add_runtime_dependency 'activesupport', '>= 4.0.0'

  s.add_development_dependency 'rake'
end
