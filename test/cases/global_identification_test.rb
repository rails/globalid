require 'helper'

class GlobalIdentificationTest < ActiveSupport::TestCase
  setup do
    @model = PersonModel.new id: 1
  end

  test 'creates a Global ID from self' do
    assert_equal GlobalID.create(@model), @model.global_id
    assert_equal GlobalID.create(@model), @model.gid
  end

  test 'creates a signed Global ID from self' do
    assert_equal SignedGlobalID.create(@model), @model.signed_global_id
    assert_equal SignedGlobalID.create(@model), @model.sgid
  end

  test 'creates a signed Global ID with purpose ' do
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.signed_global_id(for: 'login')
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.sgid(for: 'login')
  end
end
