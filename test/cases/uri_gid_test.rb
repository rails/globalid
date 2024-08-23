require 'helper'

class URI::GIDTest <  ActiveSupport::TestCase
  setup do
    @gid_string = 'gid://bcx/Person/5'
    @gid = URI::GID.parse(@gid_string)
    @cpk_gid_string = 'gid://bcx/CompositePrimaryKeyModel/tenant-key-value/id-value'
    @cpk_gid = URI::GID.parse(@cpk_gid_string)
    @ckm_gid_string = 'gid://bcx/ConfigurableKeyModel/external-id-123'
    @ckm_gid = URI::GID.parse(@ckm_gid_string)
  end

  test 'parsed' do
    assert_equal @gid.app, 'bcx'
    assert_equal @gid.model_name, 'Person'
    assert_equal @gid.model_id, '5'
    assert_equal ["tenant-key-value", "id-value"], @cpk_gid.model_id
    assert_equal @ckm_gid.app, 'bcx'
    assert_equal @ckm_gid.model_name, 'ConfigurableKeyModel'
    assert_equal @ckm_gid.model_id, 'external-id-123'
  end

  test 'parsed for non existing model class' do
    flat_id_gid = URI::GID.parse("gid://bcx/NonExistingModel/1")
    assert_equal("1", flat_id_gid.model_id)
    assert_equal("NonExistingModel", flat_id_gid.model_name)

    composite_id_gid = URI::GID.parse("gid://bcx/NonExistingModel/tenant-key-value/id-value")
    assert_equal(["tenant-key-value", "id-value"], composite_id_gid.model_id)
    assert_equal("NonExistingModel", composite_id_gid.model_name)
  end

  test 'new returns invalid gid when not checking' do
    assert URI::GID.new(*URI.split('gid:///'))
  end

  test 'create' do
    model = Person.new('5')
    assert_equal @gid_string, URI::GID.create('bcx', model).to_s
  end

  test 'create from a composite primary key model' do
    model = CompositePrimaryKeyModel.new(id: ["tenant-key-value", "id-value"])
    assert_equal @cpk_gid_string, URI::GID.create('bcx', model).to_s
  end

  test 'create from a configurable key model' do
    model = ConfigurableKeyModel.new(id: 'id-value', external_id: 'external-id-123')
    assert_equal @ckm_gid_string, URI::GID.create('bcx', model, global_id_column: :external_id).to_s
  end

  test 'build' do
    array = URI::GID.build(['bcx', 'Person', '5', nil])
    assert array

    hash = URI::GID.build(app: 'bcx', model_name: 'Person', model_id: '5', params: nil)
    assert hash

    assert_equal array, hash
  end

  test 'build with a composite primary key' do
    array = URI::GID.build(['bcx', 'CompositePrimaryKeyModel', ["tenant-key-value", "id-value"], nil])
    assert array

    hash = URI::GID.build(
      app: 'bcx',
      model_name: 'CompositePrimaryKeyModel',
      model_id: ["tenant-key-value", "id-value"],
      params: nil
    )
    assert hash

    assert_equal array, hash
    assert_equal("gid://bcx/CompositePrimaryKeyModel/tenant-key-value/id-value", array.to_s)
  end

  # NOTE: I'm not sure if this test is valuable, it's pretty duplicative with the standard
  #   test path, but with a different value passed in for `model_id:`
  test 'build with a configurable key model' do
    array = URI::GID.build(['bcx', 'ConfigurableKeyModel', 'external-id-123', nil])
    gid = URI::GID.build(
      app: 'bcx',
      model_name: 'ConfigurableKeyModel',
      model_id: 'external-id-123',
      params: nil
    )

    assert_equal array, gid
    assert_equal 'gid://bcx/ConfigurableKeyModel/external-id-123', array.to_s
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
    model = Person.new('John123')
    assert_equal 'gid://app/Person/John123', URI::GID.create('app', model).to_s
  end

  test 'non-alphanumeric' do
    model = Person.new('John Doe-Smith/Jones')
    assert_equal 'gid://app/Person/John+Doe-Smith%2FJones', URI::GID.create('app', model).to_s
  end

  test 'every part of composite primary key is encoded' do
    model = CompositePrimaryKeyModel.new(id: ["tenant key", "id value"])
    assert_equal 'gid://app/CompositePrimaryKeyModel/tenant+key/id+value', URI::GID.create('app', model).to_s
  end
end

class URI::GIDModelIDDecodingTest < ActiveSupport::TestCase
  test 'alphanumeric' do
    assert_equal 'John123', URI::GID.parse('gid://app/Person/John123').model_id
  end

  test 'non-alphanumeric' do
    assert_equal 'John Doe-Smith/Jones', URI::GID.parse('gid://app/Person/John+Doe-Smith%2FJones').model_id
  end

  test 'every part of composite primary key is decoded' do
    gid = 'gid://app/CompositePrimaryKeyModel/tenant+key+value/id+value'
    assert_equal ['tenant key value', 'id value'], URI::GID.parse(gid).model_id
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

  test 'missing model composite id' do
    err = assert_raise(URI::GID::MissingModelIdError) { URI::GID.parse('gid://bcx/CompositePrimaryKeyModel') }
    assert_match(/Unable to create a Global ID for CompositePrimaryKeyModel/, err.message)
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
    assert_invalid_app 'foo&bar'
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
