require 'helper'

class GlobalIDTest < ActiveSupport::TestCase
  test 'value equality' do
    assert_equal GlobalID.new('gid://app/model/id'), GlobalID.new('gid://app/model/id')
  end

  test 'invalid app name' do
    assert_raises ArgumentError do
      GlobalID.app = ''
    end

    assert_raises ArgumentError do
      GlobalID.app = 'blog_app'
    end

    assert_raises ArgumentError do
      GlobalID.app = nil
    end
  end
end

class GlobalIDParamEncodedTest < ActiveSupport::TestCase
  setup do
    model = Person.new(id: 'id')
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
    @person_gid = GlobalID.create(Person.new(id: 5))
    @person_uuid_gid = GlobalID.create(Person.new(uuid: @uuid))
    @person_namespaced_gid = GlobalID.create(Person::Child.new(id: 4))
    @person_model_gid = GlobalID.create(PersonModel.new(id: 1))
  end

  test 'find' do
    assert_equal Person.find(@person_gid.model_id), @person_gid.find
    assert_equal Person.find(@person_uuid_gid.model_id), @person_uuid_gid.find
    assert_equal Person::Child.find(@person_namespaced_gid.model_id), @person_namespaced_gid.find
    assert_equal PersonModel.find(@person_model_gid.model_id), @person_model_gid.find
  end

  test 'find with class' do
    assert_equal Person.find(@person_gid.model_id), @person_gid.find(only: Person)
    assert_equal Person.find(@person_uuid_gid.model_id), @person_uuid_gid.find(only: Person)
    assert_equal PersonModel.find(@person_model_gid.model_id), @person_model_gid.find(only: PersonModel)
  end

  test 'find with class no match' do
    assert_nil @person_gid.find(only: Hash)
    assert_nil @person_uuid_gid.find(only: Array)
    assert_nil @person_namespaced_gid.find(only: String)
    assert_nil @person_model_gid.find(only: Float)
  end

  test 'find with subclass' do
    assert_equal Person::Child.find(@person_namespaced_gid.model_id),
                 @person_namespaced_gid.find(only: Person)
  end

  test 'find with subclass no match' do
    assert_nil @person_namespaced_gid.find(only: String)
  end

  test 'find with module' do
    assert_equal Person.find(@person_gid.model_id), @person_gid.find(only: GlobalID::Identification)
    assert_equal Person.find(@person_uuid_gid.model_id),
                 @person_uuid_gid.find(only: GlobalID::Identification)
    assert_equal PersonModel.find(@person_model_gid.model_id),
                 @person_model_gid.find(only: ActiveModel::Model)
    assert_equal Person::Child.find(@person_namespaced_gid.model_id),
                 @person_namespaced_gid.find(only: GlobalID::Identification)
  end

  test 'find with module no match' do
    assert_nil @person_gid.find(only: Enumerable)
    assert_nil @person_uuid_gid.find(only: Forwardable)
    assert_nil @person_namespaced_gid.find(only: Base64)
    assert_nil @person_model_gid.find(only: Enumerable)
  end

  test 'find with multiple class' do
    assert_equal Person.find(@person_gid.model_id),
                 @person_gid.find(only: [0.class, Person])
    assert_equal Person.find(@person_uuid_gid.model_id),
                 @person_uuid_gid.find(only: [0.class, Person])
    assert_equal PersonModel.find(@person_model_gid.model_id),
                 @person_model_gid.find(only: [Float, PersonModel])
    assert_equal Person::Child.find(@person_namespaced_gid.model_id),
                 @person_namespaced_gid.find(only: [Person, Person::Child])
  end

  test 'find with multiple class no match' do
    assert_nil @person_gid.find(only: [0.class, Numeric])
    assert_nil @person_uuid_gid.find(only: [0.class, String])
    assert_nil @person_model_gid.find(only: [Array, Hash])
    assert_nil @person_namespaced_gid.find(only: [String, Set])
  end

  test 'find with multiple module' do
    assert_equal Person.find(@person_gid.model_id),
                 @person_gid.find(only: [Enumerable, GlobalID::Identification])
    bignum_class = RUBY_VERSION >= '2.4' ? Integer : Bignum
    assert_equal Person.find(@person_uuid_gid.model_id),
                 @person_uuid_gid.find(only: [bignum_class,
                                              GlobalID::Identification])
    assert_equal PersonModel.find(@person_model_gid.model_id),
                 @person_model_gid.find(only: [String, ActiveModel::Model])
    assert_equal Person::Child.find(@person_namespaced_gid.model_id),
                 @person_namespaced_gid.find(only: [Integer, GlobalID::Identification])
  end

  test 'find with multiple module no match' do
    assert_nil @person_gid.find(only: [Enumerable, Base64])
    assert_nil @person_uuid_gid.find(only: [Enumerable, Forwardable])
    assert_nil @person_model_gid.find(only: [Base64, Enumerable])
    assert_nil @person_namespaced_gid.find(only: [Enumerable, Forwardable])
  end

  test 'as string' do
    assert_equal 'gid://bcx/Person/5', @person_gid.to_s
    assert_equal "gid://bcx/Person/#{@uuid}", @person_uuid_gid.to_s
    assert_equal 'gid://bcx/Person::Child/4', @person_namespaced_gid.to_s
    assert_equal 'gid://bcx/PersonModel/1', @person_model_gid.to_s
  end

  test 'as param' do
    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbi81', @person_gid.to_param
    assert_equal @person_gid, GlobalID.parse('Z2lkOi8vYmN4L1BlcnNvbi81')

    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbi83ZWY5YjYxNC0zNTNjLTQzYTEtYTIwMy1hYjIzMDc4NTE5OTA', @person_uuid_gid.to_param
    assert_equal @person_uuid_gid, GlobalID.parse('Z2lkOi8vYmN4L1BlcnNvbi83ZWY5YjYxNC0zNTNjLTQzYTEtYTIwMy1hYjIzMDc4NTE5OTA')

    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbjo6Q2hpbGQvNA', @person_namespaced_gid.to_param
    assert_equal @person_namespaced_gid, GlobalID.parse('Z2lkOi8vYmN4L1BlcnNvbjo6Q2hpbGQvNA')

    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbk1vZGVsLzE', @person_model_gid.to_param
    assert_equal @person_model_gid, GlobalID.parse('Z2lkOi8vYmN4L1BlcnNvbk1vZGVsLzE')
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

  test ':app option' do
    person_gid = GlobalID.create(Person.new(id: 5))
    assert_equal 'gid://bcx/Person/5', person_gid.to_s

    person_gid = GlobalID.create(Person.new(id: 5), app: "foo")
    assert_equal 'gid://foo/Person/5', person_gid.to_s

    assert_raise ArgumentError do
      person_gid = GlobalID.create(Person.new(id: 5), app: nil)
    end
  end

  test 'equality' do
    p1 = Person.new(id: 5)
    p2 = Person.new(id: 5)
    p3 = Person.new(id: 10)
    assert_equal p1, p2
    assert_not_equal p2, p3

    gid1 = GlobalID.create(p1)
    gid2 = GlobalID.create(p2)
    gid3 = GlobalID.create(p3)
    assert_equal gid1, gid2
    assert_not_equal gid2, gid3

    # hash and eql? to match for two GlobalID's pointing to the same object
    assert_equal [gid1], [gid1, gid2].uniq
    assert_equal [gid1, gid3], [gid1, gid2, gid3].uniq

    # verify that the GlobalID's hash is different to the underlaying URI
    assert_not_equal gid1.hash, gid1.uri.hash

    # verify that URI and GlobalID do not pass the uniq test
    assert_equal [gid1, gid1.uri], [gid1, gid1.uri].uniq
  end
end

class GlobalIDCustomParamsTest < ActiveSupport::TestCase
  test 'create custom params' do
    gid = GlobalID.create(Person.new(5), hello: 'world')
    assert_equal 'world', gid.params[:hello]
  end

  test 'parse custom params' do
    gid = GlobalID.parse 'gid://bcx/Person/5?hello=world'
    assert_equal 'world', gid.params[:hello]
  end
end
