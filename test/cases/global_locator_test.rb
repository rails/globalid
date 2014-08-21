require 'helper'

class GlobalLocatorTest < ActiveSupport::TestCase
  setup do
    model = Person.new('id')
    @gid  = model.gid
    @sgid = model.sgid
  end

  test 'by GID' do
    found = GlobalID::Locator.locate(@gid)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by GID with only: restriction with match' do
    found = GlobalID::Locator.locate(@gid, only: Person)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by GID with only: restriction with match subclass' do
    instance = Person::Child.new
    gid = instance.gid
    found = GlobalID::Locator.locate(gid, only: Person)
    assert_kind_of gid.model_class, found
    assert_equal gid.model_id, found.id
  end

  test 'by GID with only: restriction with no match' do
    found = GlobalID::Locator.locate(@gid, only: String)
    assert_nil found
  end

  test 'by GID with only: restriction by multiple types' do
    found = GlobalID::Locator.locate(@gid, only: [String, Person])
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by GID with only: restriction by module' do
    found = GlobalID::Locator.locate(@gid, only: GlobalID::Identification)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by GID with only: restriction by module no match' do
    found = GlobalID::Locator.locate(@gid, only: Forwardable)
    assert_nil found
  end

  test 'by GID with only: restriction by multiple types w/module' do
    found = GlobalID::Locator.locate(@gid, only: [String, GlobalID::Identification])
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by SGID' do
    found = GlobalID::Locator.locate_signed(@sgid)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by SGID with only: restriction with match' do
    found = GlobalID::Locator.locate_signed(@sgid, only: Person)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by SGID with only: restriction with match subclass' do
    instance = Person::Child.new
    sgid = instance.sgid
    found = GlobalID::Locator.locate_signed(sgid, only: Person)
    assert_kind_of sgid.model_class, found
    assert_equal sgid.model_id, found.id
  end

  test 'by SGID with only: restriction with no match' do
    found = GlobalID::Locator.locate_signed(@sgid, only: String)
    assert_nil found
  end

  test 'by SGID with only: restriction by multiple types' do
    found = GlobalID::Locator.locate_signed(@sgid, only: [String, Person])
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by SGID with only: restriction by module' do
    found = GlobalID::Locator.locate_signed(@sgid, only: GlobalID::Identification)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by SGID with only: restriction by module no match' do
    found = GlobalID::Locator.locate_signed(@sgid, only: Enumerable)
    assert_nil found
  end

  test 'by SGID with only: restriction by multiple types w/module' do
    found = GlobalID::Locator.locate_signed(@sgid, only: [String, GlobalID::Identification])
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by GID string' do
    found = GlobalID::Locator.locate(@gid.to_s)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by SGID string' do
    found = GlobalID::Locator.locate_signed(@sgid.to_s)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by to_param encoding' do
    found = GlobalID::Locator.locate(@gid.to_param)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by non-GID returns nil' do
    assert_nil GlobalID::Locator.locate 'This is not a GID'
  end

  test 'by non-SGID returns nil' do
    assert_nil GlobalID::Locator.locate_signed 'This is not a SGID'
  end

  test 'by invalid GID URI returns nil' do
    assert_nil GlobalID::Locator.locate 'http://app/Person/1'
    assert_nil GlobalID::Locator.locate 'gid://Person/1'
    assert_nil GlobalID::Locator.locate 'gid://app/Person'
    assert_nil GlobalID::Locator.locate 'gid://app/Person/1/2'
  end

  test 'use locator with block' do
    GlobalID::Locator.use :foo do |gid|
      :foo
    end

    with_app 'foo' do
      assert_equal :foo, GlobalID::Locator.locate('gid://foo/Person/1')
    end
  end

  test 'use locator with class' do
    class BarLocator
      def locate(gid); :bar; end
    end

    GlobalID::Locator.use :bar, BarLocator.new

    with_app 'bar' do
      assert_equal :bar, GlobalID::Locator.locate('gid://bar/Person/1')
    end
  end

  test 'app locator is case insensitive' do
    GlobalID::Locator.use :insensitive do |gid|
      :insensitive
    end

    with_app 'insensitive' do
      assert_equal :insensitive, GlobalID::Locator.locate('gid://InSeNsItIvE/Person/1')
    end
  end

  test 'locator name cannot have underscore' do
    assert_raises ArgumentError do
      GlobalID::Locator.use('under_score') { |gid| 'will never be found' }
    end
  end

  private
    def with_app(app)
      old_app, GlobalID.app = GlobalID.app, app
      yield
    ensure
      GlobalID.app = old_app
    end
end
