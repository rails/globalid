require 'helper'

class GlobalIDTest < ActiveSupport::TestCase
  test 'value equality' do
    assert_equal GlobalID.new('gid://app/model/id'), GlobalID.new('gid://app/model/id')
  end
end

class URIValidationTest < ActiveSupport::TestCase
  test 'scheme' do
    assert_raise URI::BadURIError do
      GlobalID.new('gyd://app/Person/1')
    end
  end

  test 'app' do
    assert_raise URI::InvalidURIError do
      GlobalID.new('gid://Person/1')
    end
  end

  test 'path' do
    assert_raise URI::InvalidURIError do
      GlobalID.new('gid://app/Person')
    end

    assert_raise URI::InvalidURIError do
      GlobalID.new('gid://app/Person/1/2')
    end
  end
end

class GlobalIDParamEncodedTest < ActiveSupport::TestCase
  setup do
    model = Person.new('id')
    @gid = GlobalID.create(model)
  end

  test 'parsing' do
    assert_equal GlobalID.parse(@gid.to_param), @gid
  end

  test 'finding' do
    found = GlobalID.find(@gid.to_param)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end
end

class GlobalIDCreationTest < ActiveSupport::TestCase
  setup do
    @uuid = '7ef9b614-353c-43a1-a203-ab2307851990'
    @person_gid = GlobalID.create(Person.new(5))
    @person_uuid_gid = GlobalID.create(Person.new(@uuid))
    @person_namespaced_gid = GlobalID.create(Person::Child.new(4))
    @person_model_gid = GlobalID.create(PersonModel.new(id: 1))
  end

  test 'as string' do
    assert_equal 'gid://bcx/Person/5', @person_gid.to_s
    assert_equal "gid://bcx/Person/#{@uuid}", @person_uuid_gid.to_s
    assert_equal 'gid://bcx/Person::Child/4', @person_namespaced_gid.to_s
    assert_equal 'gid://bcx/PersonModel/1', @person_model_gid.to_s
  end

  test 'as param' do
    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbi81', @person_gid.to_param
    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbi83ZWY5YjYxNC0zNTNjLTQzYTEtYTIwMy1hYjIzMDc4NTE5OTA', @person_uuid_gid.to_param
    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbjo6Q2hpbGQvNA', @person_namespaced_gid.to_param
    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbk1vZGVsLzE', @person_model_gid.to_param
  end

  test 'as URI' do
    assert_equal URI('gid://bcx/Person/5'), @person_gid.uri
    assert_equal URI("gid://bcx/Person/#{@uuid}"), @person_uuid_gid.uri
    assert_equal URI('gid://bcx/Person::Child/4'), @person_namespaced_gid.uri
    assert_equal URI('gid://bcx/PersonModel/1'), @person_model_gid.uri
  end

  test 'model id' do
    assert_equal '5', @person_gid.model_id
    assert_equal @uuid, @person_uuid_gid.model_id
    assert_equal '4', @person_namespaced_gid.model_id
    assert_equal '1', @person_model_gid.model_id
  end

  test 'model name' do
    assert_equal 'Person', @person_gid.model_name
    assert_equal 'Person', @person_uuid_gid.model_name
    assert_equal 'Person::Child', @person_namespaced_gid.model_name
    assert_equal 'PersonModel', @person_model_gid.model_name
  end

  test 'model class' do
    assert_equal Person, @person_gid.model_class
    assert_equal Person, @person_uuid_gid.model_class
    assert_equal Person::Child, @person_namespaced_gid.model_class
    assert_equal PersonModel, @person_model_gid.model_class
  end
end
