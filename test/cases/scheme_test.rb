require 'helper'

class URI::GlobalIDTest <  ActiveSupport::TestCase
  test 'new' do
    uri_components = URI.split('gid://bcx/Person') + [nil, true]
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('gid://bcx/Person')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('gid://bcx/') + [nil, false]
    assert_nil URI::GlobalID.new(*uri_components).model_id
    assert_nil URI::GlobalID.new(*uri_components).model_name
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'

    uri_components = URI.split('gid://bcx/Person/5')
    assert_equal URI::GlobalID.new(*uri_components).model_id, '5'
    assert_equal URI::GlobalID.new(*uri_components).model_name, 'Person'
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'
  end

  test 'model name' do
    gid_uri = URI.parse('gid://bcx/Person/5')

    assert_equal gid_uri.model_name, 'Person'
    gid_uri.model_name = 'Model'
    assert_equal gid_uri.model_name, 'Model'

    assert_raise URI::InvalidComponentError do
      gid_uri.model_name = nil
    end
  end

  test 'model id' do
    gid_uri = URI.parse('gid://bcx/Person/5')

    assert_equal gid_uri.model_id, '5'
    gid_uri.model_id = '123456789'
    assert_equal gid_uri.model_id, '123456789'

    assert_raise URI::InvalidComponentError do
      gid_uri.model_id = nil
    end
  end

  test 'to String' do
    gid_uri = URI.parse('gid://bcx/Person/5')
    assert_equal gid_uri.to_s, 'gid://bcx/Person/5'
  end
end

class URI::GlobalIDTestBuilding <  ActiveSupport::TestCase
  test 'build' do
    uri_components = URI.split('gid://bcx/Person/5')
    assert_equal URI::GlobalID.build(*uri_components), URI::GlobalID.new(*uri_components)

    uri_components = URI.split('gid://bcx/Person')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.build(*uri_components)
    end
  end
end
