require 'helper'

class GlobalLocatorTest < ActiveSupport::TestCase
  setup do
    model = Person.new('id')
    @gid  = model.to_gid
    @sgid = model.to_sgid
    @cpk_model = CompositePrimaryKeyModel.new(id: ["tenant-key-value", "id-value"])
    @uuid_pk_model = PersonUuid.new('7ef9b614-353c-43a1-a203-ab2307851990')
    @cpk_gid = @cpk_model.to_gid
    @cpk_sgid = @cpk_model.to_sgid
  end

  test 'by GID' do
    found = GlobalID::Locator.locate(@gid)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'composite primary key model by GID' do
    found = GlobalID::Locator.locate(@cpk_gid)
    assert_kind_of @cpk_gid.model_class, found
    assert_equal ["tenant-key-value", "id-value"], found.id
  end

  test 'by GID with only: restriction with match' do
    found = GlobalID::Locator.locate(@gid, only: Person)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by GID with only: restriction with match subclass' do
    instance = Person::Child.new
    gid = instance.to_gid
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

  test 'by GID with eager loading' do
    assert_equal Person::Child.new('1', Person.new('1')),
      GlobalID::Locator.locate(
        Person::Child.new('1', Person.new('1')).to_gid,
        includes: :parent
      )
  end

  test 'by GID trying to eager load an unexisting relationship' do
    assert_raises StandardError do
      GlobalID::Locator.locate(
        Person::Child.new('1', Person.new('1')).to_gid,
        includes: :some_non_existent_relationship
      )
    end
  end

  test 'by many GIDs of one class' do
    assert_equal [ Person.new('1'), Person.new('2') ],
      GlobalID::Locator.locate_many([ Person.new('1').to_gid, Person.new('2').to_gid ])
  end

  test 'by many GIDs of a UUID pk class' do
    expected = [ @uuid_pk_model, @uuid_pk_model ]
    assert_equal expected, GlobalID::Locator.locate_many(expected.map(&:to_gid))
  end

  test 'by many GIDs of a UUID pk class with ignore missing' do
    gids_to_locate = [ @uuid_pk_model, PersonUuid.new(Person::HARDCODED_ID_FOR_MISSING_PERSON), @uuid_pk_model ]
    expected = [ @uuid_pk_model, @uuid_pk_model ]
    assert_equal expected, GlobalID::Locator.locate_many(gids_to_locate.map(&:to_gid), ignore_missing: true)
  end

  test '#locate_many by composite primary key GIDs of the same class' do
    records = [ @cpk_model, CompositePrimaryKeyModel.new(id: ["tenant-key-value2", "id-value2"]) ]
    located = GlobalID::Locator.locate_many(records.map(&:to_gid))
    assert_equal records, located
  end

  test '#locate_many by composite primary key GIDs of different classes' do
    records = [ @cpk_model, Person.new('1') ]
    located = GlobalID::Locator.locate_many(records.map(&:to_gid))
    assert_equal records, located
  end

  test 'by many GIDs of mixed classes' do
    assert_equal [ Person.new('1'), Person::Child.new('1'), Person.new('2') ],
      GlobalID::Locator.locate_many([ Person.new('1').to_gid, Person::Child.new('1').to_gid, Person.new('2').to_gid ])
  end

  test 'by many GIDs with only: restriction to match subclass' do
    assert_equal [ Person::Child.new('1') ],
      GlobalID::Locator.locate_many([ Person.new('1').to_gid, Person::Child.new('1').to_gid, Person.new('2').to_gid ], only: Person::Child)
  end

  test 'by many GIDs with eager loading' do
    assert_equal [ Person::Child.new('1', Person.new('1')), Person::Child.new('2', Person.new('2')) ],
      GlobalID::Locator.locate_many(
        [ Person::Child.new('1', Person.new('1')).to_gid, Person::Child.new('2', Person.new('2')).to_gid ],
        includes: :parent
      )
  end

  test 'by many GIDs trying to eager load an unexisting relationship' do
    assert_raises StandardError do
      GlobalID::Locator.locate_many(
        [ Person::Child.new('1', Person.new('1')).to_gid, Person::Child.new('2', Person.new('2')).to_gid ],
        includes: :some_non_existent_relationship
      )
    end
  end

  test 'by SGID' do
    found = GlobalID::Locator.locate_signed(@sgid)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by SGID of a composite primary key model' do
    found = GlobalID::Locator.locate_signed(@cpk_sgid)
    assert_kind_of @cpk_sgid.model_class, found
    assert_equal @cpk_sgid.model_id, found.id
  end

  test 'by SGID with only: restriction with match' do
    found = GlobalID::Locator.locate_signed(@sgid, only: Person)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by SGID with only: restriction with match subclass' do
    instance = Person::Child.new
    sgid = instance.to_sgid
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

  test 'by many SGIDs of one class' do
    assert_equal [ Person.new('1'), Person.new('2') ],
      GlobalID::Locator.locate_many_signed([ Person.new('1').to_sgid, Person.new('2').to_sgid ])
  end

  test 'by many SGIDs of the same composite primary key class' do
    records = [ @cpk_model, CompositePrimaryKeyModel.new(id: ["tenant-key-value2", "id-value2"]) ]
    located = GlobalID::Locator.locate_many_signed(records.map(&:to_sgid))
    assert_equal records, located
  end

  test 'by many SGIDs of mixed classes' do
    assert_equal [ Person.new('1'), Person::Child.new('1'), Person.new('2') ],
      GlobalID::Locator.locate_many_signed([ Person.new('1').to_sgid, Person::Child.new('1').to_sgid, Person.new('2').to_sgid ])
  end

  test 'by many SGIDs of composite primary key model mixed with other models' do
    records = [ @cpk_model, Person.new('1') ]
    located = GlobalID::Locator.locate_many_signed(records.map(&:to_sgid))
    assert_equal records, located
  end

  test 'by many SGIDs with only: restriction to match subclass' do
    assert_equal [ Person::Child.new('1') ],
      GlobalID::Locator.locate_many_signed([ Person.new('1').to_sgid, Person::Child.new('1').to_sgid, Person.new('2').to_sgid ], only: Person::Child)
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

  test 'by many SGID strings with for: restriction to match purpose' do
    assert_equal [ Person::Child.new('2') ],
      GlobalID::Locator.locate_many_signed([ Person.new('1').to_sgid(for: 'adoption').to_s, Person::Child.new('1').to_sgid.to_s, Person::Child.new('2').to_sgid(for: 'adoption').to_s ], for: 'adoption', only: Person::Child)
  end

  test 'by to_param encoding' do
    found = GlobalID::Locator.locate(@gid.to_param)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by to_param encoding for a composite primary key model' do
    found = GlobalID::Locator.locate(@cpk_gid.to_param)
    assert_kind_of @cpk_gid.model_class, found
    assert_equal @cpk_gid.model_id, found.id
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

  test 'locating by a GID URI with a mismatching model_id returns nil' do
    assert_nil GlobalID::Locator.locate 'gid://app/Person/1/2'
    assert_nil GlobalID::Locator.locate 'gid://app/CompositePrimaryKeyModel/tenant-key-value/id-value/something_else'
    assert_nil GlobalID::Locator.locate 'gid://app/CompositePrimaryKeyModel/tenant-key-value/'
    assert_nil GlobalID::Locator.locate 'gid://app/CompositePrimaryKeyModel/tenant-key-value'
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
      def locate(gid, options = {}); :bar; end
      def locate_many(gids, options = {}); gids.map(&:model_id); end
    end

    GlobalID::Locator.use :bar, BarLocator.new

    with_app 'bar' do
      assert_equal :bar, GlobalID::Locator.locate('gid://bar/Person/1')
      assert_equal ['1', '2'], GlobalID::Locator.locate_many(['gid://bar/Person/1', 'gid://bar/Person/2'])
    end
  end

  test 'use locator with class and single argument' do
    class DeprecatedBarLocator
      def locate(gid); :deprecated; end
      def locate_many(gids, options = {}); gids.map(&:model_id); end
    end

    GlobalID::Locator.use :deprecated, DeprecatedBarLocator.new

    with_app 'deprecated' do
      assert_deprecated(nil, GlobalID.deprecator) do
        assert_equal :deprecated, GlobalID::Locator.locate('gid://deprecated/Person/1')
      end
      assert_equal ['1', '2'], GlobalID::Locator.locate_many(['gid://deprecated/Person/1', 'gid://deprecated/Person/2'])
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

  test "by valid purpose returns right model" do
    instance = Person.new
    login_sgid = instance.to_signed_global_id(for: 'login')

    found = GlobalID::Locator.locate_signed(login_sgid.to_s, for: 'login')
    assert_kind_of login_sgid.model_class, found
    assert_equal login_sgid.model_id, found.id
  end

  test "by valid purpose with SGID returns right model" do
    instance = Person.new
    login_sgid = instance.to_signed_global_id(for: 'login')

    found = GlobalID::Locator.locate_signed(login_sgid, for: 'login')
    assert_kind_of login_sgid.model_class, found
    assert_equal login_sgid.model_id, found.id
  end

  test "by invalid purpose returns nil" do
    instance = Person.new
    login_sgid = instance.to_signed_global_id(for: 'login')

    assert_nil GlobalID::Locator.locate_signed(login_sgid.to_s, for: 'like_button')
  end

  test "by invalid purpose with SGID returns nil" do
    instance = Person.new
    login_sgid = instance.to_signed_global_id(for: 'login')

    assert_nil GlobalID::Locator.locate_signed(login_sgid, for: 'like_button')
  end

  test "by many with one record missing leading to a raise" do
    assert_raises RuntimeError do
      GlobalID::Locator.locate_many([ Person.new('1').to_gid, Person.new(Person::HARDCODED_ID_FOR_MISSING_PERSON).to_gid ])
    end
  end

  test "by many with one record missing not leading to a raise when ignoring missing" do
    assert_nothing_raised do
      GlobalID::Locator.locate_many([ Person.new('1').to_gid, Person.new(Person::HARDCODED_ID_FOR_MISSING_PERSON).to_gid ], ignore_missing: true)
    end
  end

  test 'by GID without a primary key method' do
    model = PersonWithoutPrimaryKey.new('id')
    gid = model.to_gid
    model2 = PersonWithoutPrimaryKey.new('id2')
    gid2 = model.to_gid

    found = GlobalID::Locator.locate(gid)
    assert_kind_of model.class, found
    assert_equal 'id', found.id

    found = GlobalID::Locator.locate_many([gid, gid2])
    assert_equal 2, found.length

    found = GlobalID::Locator.locate_many([gid, gid2], ignore_missing: true)
    assert_equal 2, found.length
  end

  test "can set default_locator" do
    class MyLocator
      def locate(gid)
        :my_locator
      end
    end

    with_default_locator(MyLocator.new) do
      assert_equal :my_locator, GlobalID::Locator.locate('gid://app/Person/1')
    end
  end

  private
    def with_app(app)
      old_app, GlobalID.app = GlobalID.app, app
      yield
    ensure
      GlobalID.app = old_app
    end

    def with_default_locator(default_locator)
      old_locator, GlobalID::Locator.default_locator = GlobalID::Locator.default_locator, default_locator
      yield
    ensure
      GlobalID::Locator.default_locator = old_locator
    end
end

class ScopedRecordLocatingTest < ActiveSupport::TestCase
  setup do
    @gid = Person::Scoped.new('1').to_gid
  end

  test "by GID with scoped record" do
    found = GlobalID::Locator.locate(@gid)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test "by many with scoped records" do
    assert_equal [ Person::Scoped.new('1'), Person::Scoped.new('2') ],
      GlobalID::Locator.locate_many([ Person::Scoped.new('1').to_gid, Person::Scoped.new('2').to_gid ])
  end

  test "by many with scoped and unscoped records" do
    assert_equal [ Person::Scoped.new('1'), Person.new('2') ],
      GlobalID::Locator.locate_many([ Person::Scoped.new('1').to_gid, Person.new('2').to_gid ])
  end
end
