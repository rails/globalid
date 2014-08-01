Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'activemodel-globalid'
  s.version     = '0.2.0.uri'
  s.summary     = 'Serialize models that can be found by id again (will be part of Active Model).'
  s.description = 'Serializing models to a single string makes it easy to pass references around.'

  s.required_ruby_version = '>= 1.9.3'

  s.license = 'MIT'

  s.author   = 'David Heinemeier Hansson'
  s.email    = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.files        = Dir['MIT-LICENSE', 'README.rdoc', 'lib/**/*']
  s.require_path = 'lib'

  s.add_dependency 'activesupport', '>= 4.1.0'
  s.add_dependency 'activemodel',   '>= 4.1.0'
end
