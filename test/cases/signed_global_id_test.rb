require 'helper'
require 'minitest/mock' # for stubbing Time.now as #travel doesn't have subsecond precision.

class SignedGlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(id: 5))
  end

  test 'as string' do
    assert_equal 'eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzUiLCJwdXJwb3NlIjoiZGVmYXVsdCIsImV4cGlyZXNfYXQiOm51bGx9--04a6f59140259756b22008c8c0f76ea5ed485579', @person_sgid.to_s
  end

  test 'model id' do
    assert_equal "5", @person_sgid.model_id
  end

  test 'model class' do
    assert_equal Person, @person_sgid.model_class
  end

  test 'value equality' do
    assert_equal SignedGlobalID.create(Person.new(id: 5)), SignedGlobalID.create(Person.new(id: 5))
  end

  test 'value equality with an unsigned id' do
    assert_equal GlobalID.create(Person.new(id: 5)), SignedGlobalID.create(Person.new(id: 5))
  end

  test 'to param' do
    assert_equal @person_sgid.to_s, @person_sgid.to_param
  end
end

class SignedGlobalIDVerifierTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(id: 5))
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
        SignedGlobalID.create(Person.new(id: 5))
      end
    end
  end

  test 'create accepts a :verifier' do
    with_default_verifier nil do
      expected = SignedGlobalID.create(Person.new(id: 5), verifier: VERIFIER)
      assert_equal @person_sgid, expected
    end
  end

  test 'new accepts a :verifier' do
    with_default_verifier nil do
      expected = SignedGlobalID.new(Person.new(id: 5).to_gid.uri, verifier: VERIFIER)
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
    @login_sgid = SignedGlobalID.create(Person.new(id: 5), for: 'login')
  end

  test 'sign with purpose when :for is provided' do
    assert_equal "eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzUiLCJwdXJwb3NlIjoibG9naW4iLCJleHBpcmVzX2F0IjpudWxsfQ==--4b9630f3a1fb3d7d6584d95d4fac96433ec2deef", @login_sgid.to_s
  end

  test 'sign with default purpose when no :for is provided' do
    sgid = SignedGlobalID.create(Person.new(id: 5))
    default_sgid = SignedGlobalID.create(Person.new(id: 5), for: "default")

    assert_equal "eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzUiLCJwdXJwb3NlIjoiZGVmYXVsdCIsImV4cGlyZXNfYXQiOm51bGx9--04a6f59140259756b22008c8c0f76ea5ed485579", sgid.to_s
    assert_equal sgid, default_sgid
  end

  test 'create accepts a :for' do
    expected = SignedGlobalID.create(Person.new(id: 5), for: "login")
    assert_equal @login_sgid, expected
  end

  test 'new accepts a :for' do
    expected = SignedGlobalID.new(Person.new(id: 5).to_gid.uri, for: 'login')
    assert_equal @login_sgid, expected
  end

  test 'parse returns nil when purpose mismatch' do
    sgid = @login_sgid.to_s
    assert_nil SignedGlobalID.parse sgid
    assert_nil SignedGlobalID.parse sgid, for: 'like_button'
  end

  test 'equal only with same purpose' do
    expected = SignedGlobalID.create(Person.new(id: 5), for: 'login')
    like_sgid = SignedGlobalID.create(Person.new(id: 5), for: 'like_button')
    no_purpose_sgid = SignedGlobalID.create(Person.new(id: 5))

    assert_equal @login_sgid, expected
    assert_not_equal @login_sgid, like_sgid
    assert_not_equal @login_sgid, no_purpose_sgid
  end
end

class SignedGlobalIDExpirationTest < ActiveSupport::TestCase
  setup do
    @uri = Person.new(id: 5).to_gid.uri
  end

  test 'expires_in defaults to class level expiration' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri).to_s

      travel 59.minutes
      assert SignedGlobalID.parse(encoded_sgid)

      travel 2.minutes
      assert_not SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing in expires_in overrides class level expiration' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri, expires_in: 2.hours).to_s

      travel 1.hour
      assert SignedGlobalID.parse(encoded_sgid)

      travel 1.hour + 3.seconds
      assert_not SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_in less than a second is not expired' do
    encoded_sgid = SignedGlobalID.new(@uri, expires_in: 1.second).to_s
    present = Time.now

    Time.stub :now, present + 0.5.second do
      assert SignedGlobalID.parse(encoded_sgid)
    end

    Time.stub :now, present + 2.seconds do
      assert_not SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_in nil turns off expiration checking' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri, expires_in: nil).to_s

      travel 1.hour
      assert SignedGlobalID.parse(encoded_sgid)

      travel 1.hour
      assert SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_at sets expiration date' do
    date = Date.today.end_of_day
    sgid = SignedGlobalID.new(@uri, expires_at: date)

    assert_equal date, sgid.expires_at

    travel 1.day
    assert_not SignedGlobalID.parse(sgid.to_s)
  end

  test 'passing nil expires_at turns off expiration checking' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri, expires_at: nil).to_s

      travel 4.hours
      assert SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_at overrides class level expires_in' do
    with_expiration_in 1.hour do
      date = Date.tomorrow.end_of_day
      sgid = SignedGlobalID.new(@uri, expires_at: date)

      assert_equal date, sgid.expires_at

      travel 2.hours
      assert SignedGlobalID.parse(sgid.to_s)
    end
  end

  test 'favor expires_at over expires_in' do
    sgid = SignedGlobalID.new(@uri, expires_at: Date.tomorrow.end_of_day, expires_in: 1.hour)

    travel 1.hour
    assert SignedGlobalID.parse(sgid.to_s)
  end

  private
    def with_expiration_in(expires_in)
      old_expires, SignedGlobalID.expires_in = SignedGlobalID.expires_in, expires_in
      yield
    ensure
      SignedGlobalID.expires_in = old_expires
    end
end

class SignedGlobalIDCustomParamsTest < ActiveSupport::TestCase
  test 'create custom params' do
    sgid = SignedGlobalID.create(Person.new(id: 5), hello: 'world')
    assert_equal 'world', sgid.params[:hello]
  end

  test 'parse custom params' do
    sgid = SignedGlobalID.parse('eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzU/aGVsbG89d29ybGQiLCJwdXJwb3NlIjoiZGVmYXVsdCIsImV4cGlyZXNfYXQiOm51bGx9--7c042f09483dec470fa1088b76d9fd946eb30ffa')
    assert_equal 'world', sgid.params[:hello]
  end
end
