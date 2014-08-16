require 'helper'
require 'models/person'

class SignedGlobalLocatorTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(5))
  end

  test 'locate_signed via actual SGID' do
    GlobalID::Locator.locate_signed(@person_sgid).tap do |person|
      assert person.is_a?(Person)
      assert_equal "5", person.id
    end
  end

  test 'locate_signed via string SGID' do
    GlobalID::Locator.locate_signed(@person_sgid.to_s).tap do |person|
      assert person.is_a?(Person)
      assert_equal "5", person.id
    end
  end

  test 'failure to locate via non-SGID string' do
    assert_nil GlobalID::Locator.locate_signed('This is not a SGID')
  end
end
