require 'helper'

class SignedGlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(5))
  end

  test 'as string' do
    assert_equal 'Z2lkOi8vYmN4L1BlcnNvbi81--bd2dab1418d8577e10cf93f8ec055b4b61690755', @person_sgid.to_s
  end

  test 'model id' do
    assert_equal "5", @person_sgid.model_id
  end

  test 'model class' do
    assert_equal Person, @person_sgid.model_class
  end

  test 'value equality' do
    assert_equal SignedGlobalID.create(Person.new(5)), SignedGlobalID.create(Person.new(5))
  end

  test 'value equality with an unsigned id' do
    assert_equal GlobalID.create(Person.new(5)), SignedGlobalID.create(Person.new(5))
  end
end
