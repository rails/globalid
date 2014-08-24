require 'helper'

class URI::GlobalIDTest <  ActiveSupport::TestCase
  test 'new' do
    uri_components = URI.split('gid://bcx/Person') + [ nil, true ]
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('gid://bcx/Person')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('gid://bcx/Person') + [ nil, false ]
    assert_nil URI::GlobalID.new(*uri_components).model_id
    assert_equal URI::GlobalID.new(*uri_components).model_name, 'Person'
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'

    uri_components = URI.split('gid://bcx/')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('gid://bcx/') + [ nil, false ]
    assert_nil URI::GlobalID.new(*uri_components).model_id
    assert_nil URI::GlobalID.new(*uri_components).model_name
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'


    uri_components = URI.split('gid:///')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('gid:///') + [ nil, false ]
    assert_nil URI::GlobalID.new(*uri_components).model_id
    assert_nil URI::GlobalID.new(*uri_components).model_name
    assert_nil URI::GlobalID.new(*uri_components).app

    uri_components = URI.split('//bcx/Person/1')
    assert_raise URI::BadURIError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('//bcx/Person/1') + [ nil, false ]
    assert_equal URI::GlobalID.new(*uri_components).model_id, '1'
    assert_equal URI::GlobalID.new(*uri_components).model_name, 'Person'
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'

    uri_components = URI.split('gyd://bcx/Person/1')
    assert_raise URI::BadURIError do
      URI::GlobalID.new(*uri_components)
    end

    uri_components = URI.split('gid://bcx/Person/5')
    assert_equal URI::GlobalID.new(*uri_components).model_id, '5'
    assert_equal URI::GlobalID.new(*uri_components).model_name, 'Person'
    assert_equal URI::GlobalID.new(*uri_components).app, 'bcx'
  end

  test 'app' do
    uri_components = URI.split('gid://bcx/Person/5')
    gid = URI::GlobalID.new(*uri_components)

    assert_equal gid.app, 'bcx'
    gid.app = 'app'
    assert_equal gid.app, 'app'

    assert_raise URI::InvalidComponentError do
      gid.app = nil
    end

    assert_raise URI::InvalidComponentError do
      gid.app = ''
    end

    assert_raise URI::InvalidComponentError do
      gid.app = 'app_name'
    end
  end

  test 'model name' do
    uri_components = URI.split('gid://bcx/Person/5')
    gid_uri = URI::GlobalID.new(*uri_components)

    assert_equal gid_uri.model_name, 'Person'
    gid_uri.model_name = 'Model'
    assert_equal gid_uri.model_name, 'Model'

    assert_raise URI::InvalidComponentError do
      gid_uri.model_name = nil
    end

    assert_raise URI::InvalidComponentError do
      gid_uri.model_name = ''
    end
  end

  test 'model id' do
    uri_components = URI.split('gid://bcx/Person/5')
    gid_uri = URI::GlobalID.new(*uri_components)

    assert_equal gid_uri.model_id, '5'
    gid_uri.model_id = '123456789'
    assert_equal gid_uri.model_id, '123456789'

    assert_raise URI::InvalidComponentError do
      gid_uri.model_id = nil
    end

    assert_raise URI::InvalidComponentError do
      gid_uri.model_id = ''
    end
  end

  test 'to String' do
    uri_components = URI.split('gid://bcx/Person/5')
    gid_uri = URI::GlobalID.new(*uri_components)
    assert_equal gid_uri.to_s, 'gid://bcx/Person/5'
  end
end

class URI::GlobalIDTestBuilding <  ActiveSupport::TestCase
  test 'build' do
    uri_components = URI.split('gid://bcx/Person/5')
    assert_equal URI::GlobalID.build(*uri_components),
                 URI::GlobalID.new(*uri_components)

    uri_components = URI.split('gid:///Person/1')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.build(*uri_components)
    end

    uri_components = URI.split('gid://bcx/Person')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.build(*uri_components)
    end

    uri_components = URI.split('gid://bcx/')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.build(*uri_components)
    end

    uri_components = URI.split('gid:///')
    assert_raise URI::InvalidComponentError do
      URI::GlobalID.build(*uri_components)
    end
  end
end

class URI::GlobalIDTestParsing <  ActiveSupport::TestCase
  test 'parse' do
    assert_instance_of URI::GlobalID, URI::GlobalID.parse('gid://bxc/Person/1')

    assert_raise URI::InvalidComponentError do
      URI::GlobalID.parse('gid:///Person/1')
    end

    assert_raise URI::InvalidComponentError do
      URI::GlobalID.parse('gid://bxc/Person')
    end

    assert_raise URI::InvalidComponentError do
      URI::GlobalID.parse('gid://bxc/')
    end

    assert_raise URI::InvalidComponentError do
      URI::GlobalID.parse('gid:///')
    end
  end
end
