require 'helper'

class SignedGlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(5))
  end

  test '.parse raises when verifier is nil' do
    begin
      gid = @person_sgid.to_s
      SignedGlobalID.verifier = nil
      assert_raise ArgumentError do
        SignedGlobalID.parse(gid)
      end
    ensure
      SignedGlobalID.verifier = VERIFIER
    end
  end

  test '.create raises when verifier is nil' do
    begin
      SignedGlobalID.verifier = nil
      assert_raise ArgumentError do
        SignedGlobalID.create(Person.new(5))
      end
    ensure
      SignedGlobalID.verifier = VERIFIER
    end
  end

  test 'accepts a verifier on .create' do
    begin
      SignedGlobalID.verifier = nil
      expected = SignedGlobalID.create(Person.new(5), verifier: VERIFIER)
      assert_equal @person_sgid, expected
    ensure
      SignedGlobalID.verifier = VERIFIER
    end
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

  test 'to param' do
    assert_equal @person_sgid.to_s, @person_sgid.to_param
  end
end
