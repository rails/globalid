require 'helper'

class GlobalLocatorTest < ActiveSupport::TestCase
  setup do
    model = Person.new(id: 'id')
    @gid  = model.to_gid
    @sgid = model.to_sgid
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

  test 'by many GIDs of one class' do
    assert_equal [ Person.new(id: '1'), Person.new(id: '2') ],
      GlobalID::Locator.locate_many([ Person.new(id: '1').to_gid, Person.new(id: '2').to_gid ])
  end

  test 'by many GIDs of mixed classes' do
    assert_equal [ Person.new(id: '1'), Person::Child.new(id: '1'), Person.new(id: '2') ],
      GlobalID::Locator.locate_many([ Person.new(id: '1').to_gid, Person::Child.new(id: '1').to_gid, Person.new(id: '2').to_gid ])
  end

  test 'by many GIDs with only: restriction to match subclass' do
    assert_equal [ Person::Child.new(id: '1') ],
      GlobalID::Locator.locate_many([ Person.new(id: '1').to_gid, Person::Child.new(id: '1').to_gid, Person.new(id: '2').to_gid ], only: Person::Child)
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
    assert_equal [ Person.new(id: '1'), Person.new(id: '2') ],
      GlobalID::Locator.locate_many_signed([ Person.new(id: '1').to_sgid, Person.new(id: '2').to_sgid ])
  end

  test 'by many SGIDs of mixed classes' do
    assert_equal [ Person.new(id: '1'), Person::Child.new(id: '1'), Person.new(id: '2') ],
      GlobalID::Locator.locate_many_signed([ Person.new(id: '1').to_sgid, Person::Child.new(id: '1').to_sgid, Person.new(id: '2').to_sgid ])
  end

  test 'by many SGIDs with only: restriction to match subclass' do
    assert_equal [ Person::Child.new(id: '1') ],
      GlobalID::Locator.locate_many_signed([ Person.new(id: '1').to_sgid, Person::Child.new(id: '1').to_sgid, Person.new(id: '2').to_sgid ], only: Person::Child)
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
    assert_equal [ Person::Child.new(id: '2') ],
      GlobalID::Locator.locate_many_signed([ Person.new(id: '1').to_sgid(for: 'adoption').to_s, Person::Child.new(id: '1').to_sgid.to_s, Person::Child.new(id: '2').to_sgid(for: 'adoption').to_s ], for: 'adoption', only: Person::Child)
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
      def locate_many(gids, options = {}); gids.map(&:model_id); end
    end

    GlobalID::Locator.use :bar, BarLocator.new

    with_app 'bar' do
      assert_equal :bar, GlobalID::Locator.locate('gid://bar/Person/1')
      assert_equal ['1', '2'], GlobalID::Locator.locate_many(['gid://bar/Person/1', 'gid://bar/Person/2'])
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
      GlobalID::Locator.locate_many([ Person.new(id: '1').to_gid, Person.new(Person::HARDCODED_ID_FOR_MISSING_PERSON).to_gid ])
    end
  end

  test "by many with one record missing not leading to a raise when ignoring missing" do
    assert_nothing_raised do
      GlobalID::Locator.locate_many([ Person.new(id: '1').to_gid, Person.new(Person::HARDCODED_ID_FOR_MISSING_PERSON).to_gid ], ignore_missing: true)
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

class ScopedRecordLocatingTest < ActiveSupport::TestCase
  setup do
    @gid = Person::Scoped.new(id: '1').to_gid
  end

  test "by GID with scoped record" do
    found = GlobalID::Locator.locate(@gid)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test "by many with scoped records" do
    assert_equal [ Person::Scoped.new(id: '1'), Person::Scoped.new(id: '2') ],
      GlobalID::Locator.locate_many([ Person::Scoped.new(id: '1').to_gid, Person::Scoped.new(id: '2').to_gid ])
  end

  test "by many with scoped and unscoped records" do
    assert_equal [ Person::Scoped.new(id: '1'), Person.new(id: '2') ],
      GlobalID::Locator.locate_many([ Person::Scoped.new(id: '1').to_gid, Person.new(id: '2').to_gid ])
  end
end
