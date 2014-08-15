require 'helper'
require 'active_model/global_locator'

require 'models/person'

class GlobalLocatorTest < ActiveSupport::TestCase
  setup do
    @person_gid = GlobalID.create(Person.new(5))
  end

  test 'locate via actual GID' do
    ActiveModel::GlobalLocator.locate(@person_gid).tap do |person|
      assert person.is_a?(Person)
      assert_equal "5", person.id
    end
  end

  test 'locate via string GID' do
    ActiveModel::GlobalLocator.locate(@person_gid.to_s).tap do |person|
      assert person.is_a?(Person)
      assert_equal "5", person.id
    end
  end

  test 'failure to locate via non-GID string' do
    assert_nil ActiveModel::GlobalLocator.locate "This is not a GID"
  end
end
