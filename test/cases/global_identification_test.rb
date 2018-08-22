require 'helper'

class GlobalIdentificationTest < ActiveSupport::TestCase
  setup do
    @model = PersonModel.new id: 1
  end

  test 'creates a Global ID from self' do
    assert_equal GlobalID.create(@model), @model.to_global_id
    assert_equal GlobalID.create(@model), @model.to_gid
  end

  test 'creates a Global ID with custom params' do
    assert_equal GlobalID.create(@model, some: 'param'), @model.to_global_id(some: 'param')
    assert_equal GlobalID.create(@model, some: 'param'), @model.to_gid(some: 'param')
  end

  test 'creates a signed Global ID from self' do
    assert_equal SignedGlobalID.create(@model), @model.to_signed_global_id
    assert_equal SignedGlobalID.create(@model), @model.to_sgid
  end

  test 'creates a signed Global ID with purpose ' do
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_signed_global_id(for: 'login')
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_sgid(for: 'login')
  end

  test 'creates a signed Global ID with custom params' do
    assert_equal SignedGlobalID.create(@model, some: 'param'), @model.to_signed_global_id(some: 'param')
    assert_equal SignedGlobalID.create(@model, some: 'param'), @model.to_sgid(some: 'param')
  end

  test 'dup should clear memoized to_global_id' do
    global_id = @model.to_global_id
    dup_model = @model.dup
    dup_model.id = @model.id + 1
    dup_global_id = dup_model.to_global_id
    assert_not_equal global_id, dup_global_id
  end
end
