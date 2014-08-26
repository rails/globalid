require 'helper'

class GlobalIdentificationTest < ActiveSupport::TestCase
  setup do
    @model = PersonModel.new id: 1
  end

  test 'creates a Global ID from self' do
    assert_equal GlobalID.create(@model), @model.to_global_id
    assert_equal GlobalID.create(@model), @model.to_gid

    assert_deprecated { assert_equal GlobalID.create(@model), @model.global_id }
    assert_deprecated { assert_equal GlobalID.create(@model), @model.gid }
  end

  test 'creates a signed Global ID from self' do
    assert_equal SignedGlobalID.create(@model), @model.to_signed_global_id
    assert_equal SignedGlobalID.create(@model), @model.to_sgid

    assert_deprecated { assert_equal SignedGlobalID.create(@model), @model.signed_global_id }
    assert_deprecated { assert_equal SignedGlobalID.create(@model), @model.sgid }
  end

  test 'creates a signed Global ID with purpose ' do
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_signed_global_id(for: 'login')
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_sgid(for: 'login')

    assert_deprecated { assert_equal SignedGlobalID.create(@model, for: 'login'), @model.signed_global_id(for: 'login') }
    assert_deprecated { assert_equal SignedGlobalID.create(@model, for: 'login'), @model.sgid(for: 'login') }
  end

  test 'deprecated aliases give way to methods defined on the class' do
    user = UnixUser.new(1)

    assert_not_deprecated { assert_equal 'group ID', user.gid }
    assert_not_deprecated { assert_equal 'set group ID', user.sgid }
    assert_not_deprecated { assert_equal 'global_id', user.global_id }

    assert_deprecated { assert_equal SignedGlobalID.create(user), user.signed_global_id }

    assert_respond_to user, :gid
    assert_respond_to user, :sgid
    assert_respond_to user, :global_id
    assert_respond_to user, :signed_global_id
  end
end
