require 'helper'

class URI::GIDTest <  ActiveSupport::TestCase
  setup do
    @gid_string = 'gid://bcx/Person/5'
    @gid = URI::GID.parse(@gid_string)
  end

  test 'parsed' do
    assert_equal @gid.app, 'bcx'
    assert_equal @gid.model_name, 'Person'
    assert_equal @gid.model_id, '5'
  end

  test 'new returns invalid gid when not checking' do
    assert URI::GID.new(*URI.split('gid:///'))
  end

  test 'create' do
    model = Person.new(id: '5')
    assert_equal @gid_string, URI::GID.create('bcx', model).to_s
  end

  test 'build' do
    array = URI::GID.build(['bcx', 'Person', '5', nil])
    assert array

    hash = URI::GID.build(app: 'bcx', model_name: 'Person', model_id: '5', params: nil)
    assert hash

    assert_equal array, hash
  end

  test 'build with wrong ordered array creates a wrong ordered gid' do
    assert_not_equal @gid_string, URI::GID.build(['Person', '5', 'bcx', nil]).to_s
  end

  test 'as String' do
    assert_equal @gid_string, @gid.to_s
  end

  test 'equal' do
    assert_equal @gid, URI::GID.parse(@gid_string)
    assert_not_equal @gid, URI::GID.parse('gid://bcxxx/Persona/1')
  end
end

class URI::GIDModelIDEncodingTest < ActiveSupport::TestCase
  test 'alphanumeric' do
    model = Person.new(id: 'John123')
    assert_equal 'gid://app/Person/John123', URI::GID.create('app', model).to_s
  end

  test 'non-alphanumeric' do
    model = Person.new(id: 'John Doe-Smith/Jones')
    assert_equal 'gid://app/Person/John+Doe-Smith%2FJones', URI::GID.create('app', model).to_s
  end
end

class URI::GIDModelIDDecodingTest < ActiveSupport::TestCase
  test 'alphanumeric' do
    assert_equal 'John123', URI::GID.parse('gid://app/Person/John123').model_id
  end

  test 'non-alphanumeric' do
    assert_equal 'John Doe-Smith/Jones', URI::GID.parse('gid://app/Person/John+Doe-Smith%2FJones').model_id
  end
end

class URI::GIDValidationTest < ActiveSupport::TestCase
  test 'missing app' do
    assert_invalid_component 'gid:///Person/1'
  end

  test 'missing path' do
    assert_invalid_component 'gid://bcx/'
  end

  test 'missing model id' do
    err = assert_raise(URI::GID::MissingModelIdError) { URI::GID.parse('gid://bcx/Person') }
    assert_match(/Unable to create a Global ID for Person/, err.message)
  end

  test 'too many model ids' do
    assert_invalid_component 'gid://bcx/Person/1/2'
  end

  test 'empty' do
    assert_invalid_component 'gid:///'
  end

  test 'invalid schemes' do
    assert_bad_uri 'http://bcx/Person/5'
    assert_bad_uri 'gyd://bcx/Person/5'
    assert_bad_uri '//bcx/Person/5'
  end

  private
    def assert_invalid_component(uri)
      assert_raise(URI::InvalidComponentError) { URI::GID.parse(uri) }
    end

    def assert_bad_uri(uri)
      assert_raise(URI::BadURIError) { URI::GID.parse(uri) }
    end
end

class URI::GIDAppValidationTest < ActiveSupport::TestCase
  test 'nil or blank apps are invalid' do
    assert_invalid_app nil
    assert_invalid_app ''
  end

  test 'apps containing non alphanumeric characters are invalid' do
    assert_invalid_app 'foo/bar'
    assert_invalid_app 'foo:bar'
    assert_invalid_app 'foo_bar'
  end

  test 'app with hyphen is allowed' do
    assert_equal 'foo-bar', URI::GID.validate_app('foo-bar')
  end

  private
    def assert_invalid_app(value)
      assert_raise(ArgumentError) { URI::GID.validate_app(value) }
    end
end

class URI::GIDParamsTest < ActiveSupport::TestCase
  setup do
    @gid = URI::GID.create('bcx', Person.find(5), hello: 'world')
  end

  test 'indifferent key access' do
    assert_equal 'world', @gid.params[:hello]
    assert_equal 'world', @gid.params['hello']
  end

  test 'integer option' do
    gid = URI::GID.build(['bcx', 'Person', '5', integer: 20])
    assert_equal '20', gid.params[:integer]
  end

  test 'multi value params returns last value' do
    gid = URI::GID.build(['bcx', 'Person', '5', multi: %w(one two)])
    exp = { 'multi' => 'two' }
    assert_equal exp, gid.params
  end

  test 'as String' do
    assert_equal 'gid://bcx/Person/5?hello=world', @gid.to_s
  end

  test 'immutable params' do
    @gid.params[:param] = 'value'
    assert_not_equal 'gid://bcx/Person/5?hello=world&param=value', @gid.to_s
  end
end
