require 'helper'

class SignedGlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(5))
  end

  test 'as string' do
    assert_equal 'eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzUiLCJwdXJwb3NlIjoiZGVmYXVsdCJ9--5cbdd043da53ae22418ed64605825e69ca2521fc', @person_sgid.to_s
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

class SignedGlobalIDPurposeTest < ActiveSupport::TestCase
  setup do
    @login_sgid = SignedGlobalID.create(Person.new(5), for: 'login')
  end

  test 'sign with purpose when :for is provided' do
    assert_equal "eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzUiLCJwdXJwb3NlIjoibG9naW4ifQ==--9e834bc725a12a807e94141754f6d00eecb4925d", @login_sgid.to_s
  end

  test 'sign with default purpose when no :for is provided' do
    sgid = SignedGlobalID.create(Person.new(5))
    default_sgid = SignedGlobalID.create(Person.new(5), for: "default")

    assert_equal "eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzUiLCJwdXJwb3NlIjoiZGVmYXVsdCJ9--5cbdd043da53ae22418ed64605825e69ca2521fc", sgid.to_s
    assert_equal sgid, default_sgid
  end

  test 'create accepts a :for' do
    expected = SignedGlobalID.create(Person.new(5), for: "login")
    assert_equal @login_sgid, expected
  end

  test 'new accepts a :for' do
    expected = SignedGlobalID.new(Person.new(5).gid.uri, for: 'login')
    assert_equal @login_sgid, expected
  end

  test 'parse returns nil when purpose mismatch' do
    sgid = @login_sgid.to_s
    assert_nil SignedGlobalID.parse sgid
    assert_nil SignedGlobalID.parse sgid, for: 'like_button'
  end

  test 'equal only with same purpose' do
    expected = SignedGlobalID.create(Person.new(5), for: 'login')
    like_sgid = SignedGlobalID.create(Person.new(5), for: 'like_button')
    no_purpose_sgid = SignedGlobalID.create(Person.new(5))

    assert_equal @login_sgid, expected
    assert_not_equal @login_sgid, like_sgid
    assert_not_equal @login_sgid, no_purpose_sgid
  end
end
