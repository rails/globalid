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
end
