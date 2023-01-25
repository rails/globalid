require 'helper'
require 'minitest/mock' # for stubbing Time.now as #travel doesn't have subsecond precision.

class SignedGlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_sgid = SignedGlobalID.create(Person.new(5))
  end

  test 'as string' do
    assert_equal 'eyJfcmFpbHMiOnsibWVzc2FnZSI6IkltZHBaRG92TDJKamVDOVFaWEp6YjI0dk5TST0iLCJleHAiOm51bGwsInB1ciI6ImRlZmF1bHQifX0=--aca9c546b5cb896c06140f59732edf87ae7e2536', @person_sgid.to_s
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

class SignedGlobalIDPurposeTest < ActiveSupport::TestCase
  setup do
    @login_sgid = SignedGlobalID.create(Person.new(5), for: 'login')
  end

  test 'sign with purpose when :for is provided' do
    assert_equal "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkltZHBaRG92TDJKamVDOVFaWEp6YjI0dk5TST0iLCJleHAiOm51bGwsInB1ciI6ImxvZ2luIn19--c39de01a211a37d62b4773d1da7bff94ba2ec176", @login_sgid.to_s
    assert_not_equal @login_sgid, SignedGlobalID.create(Person.new(5), for: 'like-button')
  end

  test 'sign with default purpose when no :for is provided' do
    sgid = SignedGlobalID.create(Person.new(5))
    default_sgid = SignedGlobalID.create(Person.new(5), for: "default")

    assert_equal "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkltZHBaRG92TDJKamVDOVFaWEp6YjI0dk5TST0iLCJleHAiOm51bGwsInB1ciI6ImRlZmF1bHQifX0=--aca9c546b5cb896c06140f59732edf87ae7e2536", sgid.to_s
    assert_equal sgid, default_sgid
  end

  test 'create accepts a :for' do
    expected = SignedGlobalID.create(Person.new(5), for: "login")
    assert_equal @login_sgid, expected
  end

  test 'new accepts a :for' do
    expected = SignedGlobalID.new(Person.new(5).to_gid.uri, for: 'login')
    assert_equal @login_sgid, expected
  end

  test 'parse returns nil when purpose mismatch' do
    sgid = @login_sgid.to_s
    assert_nil SignedGlobalID.parse sgid
    assert_nil SignedGlobalID.parse sgid, for: 'like_button'
  end

  test 'parse is backwards compatible with the self validated metadata' do
    legacy_sgid = "eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzUiLCJwdXJwb3NlIjoibG9naW4iLCJleHBpcmVzX2F0IjpudWxsfQ==--4b9630f3a1fb3d7d6584d95d4fac96433ec2deef"
    assert_equal @login_sgid, SignedGlobalID.parse(legacy_sgid, for: 'login')
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

class SignedGlobalIDExpirationTest < ActiveSupport::TestCase
  setup do
    @uri = Person.new(5).to_gid.uri
  end

  test 'expires_in defaults to class level expiration' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri).to_s

      travel 59.minutes
      assert_not_nil SignedGlobalID.parse(encoded_sgid)

      travel 2.minutes
      assert_nil SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing in expires_in overrides class level expiration' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri, expires_in: 2.hours).to_s

      travel 1.hour
      assert_not_nil SignedGlobalID.parse(encoded_sgid)

      travel 1.hour + 3.seconds
      assert_nil SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_in less than a second is not expired' do
    encoded_sgid = SignedGlobalID.new(@uri, expires_in: 1.second).to_s
    present = Time.now

    Time.stub :now, present + 0.5.second do
      assert_not_nil SignedGlobalID.parse(encoded_sgid)
    end

    Time.stub :now, present + 2.seconds do
      assert_nil SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_in nil turns off expiration checking' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri, expires_in: nil).to_s

      travel 1.hour
      assert_not_nil SignedGlobalID.parse(encoded_sgid)

      travel 1.hour
      assert_not_nil SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_at sets expiration date' do
    date = Date.today.end_of_day
    sgid = SignedGlobalID.new(@uri, expires_at: date)

    assert_equal date, sgid.expires_at

    travel 1.day
    assert_nil SignedGlobalID.parse(sgid.to_s)
  end

  test 'passing nil expires_at turns off expiration checking' do
    with_expiration_in 1.hour do
      encoded_sgid = SignedGlobalID.new(@uri, expires_at: nil).to_s

      travel 4.hours
      assert_not_nil SignedGlobalID.parse(encoded_sgid)
    end
  end

  test 'passing expires_at overrides class level expires_in' do
    with_expiration_in 1.hour do
      date = Date.tomorrow.end_of_day
      sgid = SignedGlobalID.new(@uri, expires_at: date)

      assert_equal date, sgid.expires_at

      travel 2.hours
      assert_not_nil SignedGlobalID.parse(sgid.to_s)
    end
  end

  test 'favor expires_at over expires_in' do
    sgid = SignedGlobalID.new(@uri, expires_at: Date.tomorrow.end_of_day, expires_in: 1.hour)

    travel 1.hour
    assert_not_nil SignedGlobalID.parse(sgid.to_s)
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
    sgid = SignedGlobalID.create(Person.new(5), hello: 'world')
    assert_equal 'world', sgid.params[:hello]
  end

  test 'parse custom params' do
    sgid = SignedGlobalID.parse('eyJnaWQiOiJnaWQ6Ly9iY3gvUGVyc29uLzU/aGVsbG89d29ybGQiLCJwdXJwb3NlIjoiZGVmYXVsdCIsImV4cGlyZXNfYXQiOm51bGx9--7c042f09483dec470fa1088b76d9fd946eb30ffa')
    assert_equal 'world', sgid.params[:hello]
  end
end
