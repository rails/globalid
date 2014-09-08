require 'helper'

class URI::GlobalIDTest <  ActiveSupport::TestCase
  test 'new' do
    uri_components = URI.split('gid://bcx/Person/5')
    assert_equal URI::GlobalID.new(*uri_components).model_id, '5'
    assert_equal URI::GlobalID.new(*uri_components).model_name, 'Person'
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'
  end

  test 'URI::InvalidComponentError is raised when arg_check is true and components are missing' do
    uri_components = URI.split('gid://bcx/Person') + [ nil, true ]
    assert_invalid_component uri_components

    uri_components = URI.split('gid://bcx/') + [ nil, true ]
    assert_invalid_component uri_components

    uri_components = URI.split('gid:///') + [ nil, true ]
    assert_invalid_component uri_components
  end

  test 'URI::InvalidComponentError is raised when arg_check is nil and components are missing' do
    uri_components = URI.split('gid://bcx/Person')
    assert_invalid_component uri_components

    uri_components = URI.split('gid://bcx/')
    assert_invalid_component uri_components

    uri_components = URI.split('gid:///')
    assert_invalid_component uri_components
  end

  test 'nothing is raised when arg_check is false and components are missing' do
    uri_components = URI.split('gid://bcx/Person') + [ nil, false ]
    assert_nil URI::GlobalID.new(*uri_components).model_id
    assert_equal URI::GlobalID.new(*uri_components).model_name, 'Person'
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'

    uri_components = URI.split('gid://bcx/') + [ nil, false ]
    assert_nil URI::GlobalID.new(*uri_components).model_id
    assert_nil URI::GlobalID.new(*uri_components).model_name
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'

    uri_components = URI.split('gid:///') + [ nil, false ]
    assert_nil URI::GlobalID.new(*uri_components).model_id
    assert_nil URI::GlobalID.new(*uri_components).model_name
    assert_nil URI::GlobalID.new(*uri_components).app

    uri_components = URI.split('//bcx/Person/1') + [ nil, false ]
    assert_equal URI::GlobalID.new(*uri_components).model_id, '1'
    assert_equal URI::GlobalID.new(*uri_components).model_name, 'Person'
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'
  end

  test 'raises URI::InvalidComponentError when one or more components are missing' do
    uri_components = URI.split('gid://bcx/Person')
    assert_invalid_component uri_components

    uri_components = URI.split('gid://bcx/')
    assert_invalid_component uri_components

    uri_components = URI.split('gid:///')
    assert_invalid_component uri_components
  end

  test 'raises URI::BadURIError when the scheme is different from gid' do
    uri_components = URI.split('//bcx/Person/1')
    assert_bad_uri uri_components

    uri_components = URI.split('gyd://bcx/Person/1')
    assert_bad_uri uri_components
  end

  test 'to String' do
    uri_components = URI.split('gid://bcx/Person/5')
    gid_uri = URI::GlobalID.new(*uri_components)
    assert_equal gid_uri.to_s, 'gid://bcx/Person/5'
  end

  private

    def assert_invalid_component(uri_components)
      assert_raise(URI::InvalidComponentError) do
        URI::GlobalID.new(*uri_components)
      end
    end

    def assert_bad_uri(uri_components)
      assert_raise(URI::BadURIError) { URI::GlobalID.new(*uri_components) }
    end
end

class URI::GlobalIDTestSettingAppValue <  ActiveSupport::TestCase
  setup do
    uri_components = URI.split('gid://bcx/Person/5')
    @gid_uri = URI::GlobalID.new(*uri_components)
  end

  test 'changes the value of app component' do
    assert_equal @gid_uri.app, 'bcx'
    @gid_uri.app = 'app'
    assert_equal @gid_uri.app, 'app'
  end

  test 'values other than alphanumeric characters are invalid' do
    assert_invalid_app @gid_uri, nil
    assert_invalid_app @gid_uri, ''
    assert_invalid_app @gid_uri, 'app_name'
  end

  private

    def assert_invalid_app(gid_uri, value)
      assert_raise(URI::InvalidComponentError) { gid_uri.app = value }
    end
end

class URI::GlobalIDTestSettingModelNameValue <  ActiveSupport::TestCase
  setup do
    uri_components = URI.split('gid://bcx/Person/5')
    @gid_uri = URI::GlobalID.new(*uri_components)
  end

  test 'changes the value of model_name component' do
    assert_equal @gid_uri.model_name, 'Person'
    @gid_uri.model_name = 'Project'
    assert_equal @gid_uri.model_name, 'Project'
  end

  test 'value can not be nil' do
    assert_invalid_model_name @gid_uri, nil
  end

  test 'value can not be an empty String' do
    assert_invalid_model_name @gid_uri, ''
  end

  private

    def assert_invalid_model_name(gid_uri, value)
      assert_raise(URI::InvalidComponentError) { gid_uri.model_name = value }
    end
end

class URI::GlobalIDTestSettingModelIDValue <  ActiveSupport::TestCase
  setup do
    uri_components = URI.split('gid://bcx/Person/5')
    @gid_uri = URI::GlobalID.new(*uri_components)
  end

  test 'changes the value of model_name component' do
    assert_equal @gid_uri.model_id, '5'
    @gid_uri.model_id = '123456789'
    assert_equal @gid_uri.model_id, '123456789'
  end

  test 'value can not be nil' do
    assert_invalid_model_id @gid_uri, nil
  end

  test 'value can not be an empty String' do
    assert_invalid_model_id @gid_uri, ''
  end

  private

    def assert_invalid_model_id(gid_uri, value)
      assert_raise(URI::InvalidComponentError) { gid_uri.model_id = value }
    end
end

class URI::GlobalIDTestBuilding <  ActiveSupport::TestCase
  test 'returs an instance of URI:GlobalID' do
    uri_components = URI.split('gid://bcx/Person/5')
    assert_instance_of URI::GlobalID, URI::GlobalID.build(*uri_components)
  end

  test 'build' do
    uri_components = URI.split('gid://bcx/Person/5')
    assert_equal URI::GlobalID.build(*uri_components),
                 URI::GlobalID.new(*uri_components)
  end

  test 'raises URI::InvalidComponentError when one or more components are missing' do
    uri_components = URI.split('gid:///Person/1')
    assert_invalid_component uri_components

    uri_components = URI.split('gid://bcx/Person')
    assert_invalid_component uri_components

    uri_components = URI.split('gid://bcx/')
    assert_invalid_component uri_components

    uri_components = URI.split('gid:///')
    assert_invalid_component uri_components
  end

  private

    def assert_invalid_component(uri_components)
      assert_raise(URI::InvalidComponentError) do
        URI::GlobalID.build(*uri_components)
      end
    end
end

class URI::GlobalIDTestParsing <  ActiveSupport::TestCase
  test 'returs an instance of URI:GlobalID' do
    assert_instance_of URI::GlobalID, URI::GlobalID.parse('gid://bcx/Person/1')
  end

  test 'returns a valid URI' do
    uri = 'gid://bcx/Person/1'
    assert_equal uri , URI::GlobalID.parse(uri).to_s
  end

  test 'raises URI::InvalidComponentError when a component is missing' do
    assert_invalid_component 'gid:///Person/1'
    assert_invalid_component 'gid://bcx/Person'
    assert_invalid_component 'gid://bcx/'
    assert_invalid_component 'gid:///'
  end

  test 'raises URI::BadURIError when the scheme is different from gid' do
    assert_bad_uri 'id://bcx/Person/5'
    assert_bad_uri 'gi://bcx/Person/5'
    assert_bad_uri 'gdi://bcx/Person/5'
    assert_bad_uri '//bcx/Person/5'
  end

  private

    def assert_invalid_component(uri)
      assert_raise(URI::InvalidComponentError) { URI::GlobalID.parse(uri) }
    end

    def assert_bad_uri(uri_components)
      assert_raise(URI::BadURIError) { URI::GlobalID.parse(*uri_components) }
    end
end

class URI::GlobalIDTestCreating < ActiveSupport::TestCase
  setup do
    @app = 'bcx'
    @model = Person.new('1')
  end

  test 'returns an instance of URI::GlobalID' do
    assert_instance_of URI::GlobalID, URI::GlobalID.create(@app, @model)
  end

  test 'creates a valid gid' do
    assert_equal 'gid://bcx/Person/1', URI::GlobalID.create(@app, @model).to_s
  end
end

class URI::GlobalIDTestValidatingApp < ActiveSupport::TestCase
  test 'nil is an invalid value' do
    assert_invalid_app nil
  end

  test 'values containing non alphanumeric characters are invalid' do
    assert_invalid_app 'foo/bar'
    assert_invalid_app 'foo:bar'
    assert_invalid_app 'foo_bar'
  end

  test 'value with hyphen is allowed' do
    assert_equal 'foo-bar', URI::GlobalID.validate_app('foo-bar')
  end

  test 'value with @ returns app part after @' do
    assert_equal 'bar', URI::GlobalID.validate_app('foo@bar')
  end

  private

    def assert_invalid_app(value)
      assert_raise(ArgumentError) { URI::GlobalID.validate_app(value) }
    end
end
