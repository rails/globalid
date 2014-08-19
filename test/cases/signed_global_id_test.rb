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

  test 'to param' do
    assert_equal @person_sgid.to_s, @person_sgid.to_param
  end
end

class SignedGlobalIDVerifierTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(5))
  end

  test 'parse raises when default verifier is nil' do
    gid = @person_sgid.to_s
    with_default_verifier nil do
      assert_raise ArgumentError do
        SignedGlobalID.parse(gid)
      end
    end
  end

  test 'create raises when default verifier is nil' do
    with_default_verifier nil do
      assert_raise ArgumentError do
        SignedGlobalID.create(Person.new(5))
      end
    end
  end

  test 'create accepts a :verifier' do
    with_default_verifier nil do
      expected = SignedGlobalID.create(Person.new(5), verifier: VERIFIER)
      assert_equal @person_sgid, expected
    end
  end

  test 'new accepts a :verifier' do
    with_default_verifier nil do
      expected = SignedGlobalID.new(Person.new(5).gid.uri, verifier: VERIFIER)
      assert_equal @person_sgid, expected
    end
  end

  def with_default_verifier(verifier)
    original, SignedGlobalID.verifier = SignedGlobalID.verifier, verifier
    yield
  ensure
    SignedGlobalID.verifier = original
  end
end
