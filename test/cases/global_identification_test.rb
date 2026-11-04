# frozen_string_literal: true
require 'helper'

class GlobalIdentificationTest < ActiveSupport::TestCase
  setup do
    @model = PersonModel.new id: 1
  end

  test 'creates a Global ID from self' do
    assert_equal GlobalID.create(@model), @model.to_global_id
    assert_equal GlobalID.create(@model), @model.to_gid
    assert_equal PersonModel.build_global_id(@model), @model.to_gid
    assert_equal PersonModel.build_global_id(1), @model.to_global_id
  end

  test 'creates a Global ID with custom params' do
    assert_equal GlobalID.create(@model, some: 'param'), @model.to_global_id(some: 'param')
    assert_equal GlobalID.create(@model, some: 'param'), @model.to_gid(some: 'param')
    assert_equal PersonModel.build_global_id(@model, some: 'param'), @model.to_gid(some: 'param')
    assert_equal PersonModel.build_global_id(1, some: 'param'), @model.to_global_id(some: 'param')
  end

  test 'creates a Global ID with a custom app' do
    model = CustomAppPersonModel.new id: 1

    assert_equal GlobalID.create(model, app: 'custom-app'), model.to_global_id
    assert_equal GlobalID.create(model, app: 'custom-app'), model.to_gid
    assert_equal GlobalID.create(model, app: 'other-app'), model.to_global_id(app: 'other-app')
    assert_equal GlobalID.create(model, app: 'custom-app'), CustomAppPersonModel.build_global_id(1)
  end

  test 'to_gid delegates to overridden to_global_id' do
    model = OverriddenToGlobalIDPersonModel.new id: 1

    assert_equal GlobalID.create(model, app: 'override-app'), model.to_gid
    assert_equal GlobalID.create(model, app: 'override-app'), OverriddenToGlobalIDPersonModel.build_global_id(1)
  end

  test 'creates a signed Global ID from self' do
    assert_equal SignedGlobalID.create(@model), @model.to_signed_global_id
    assert_equal SignedGlobalID.create(@model), @model.to_sgid
    assert_equal PersonModel.build_signed_global_id(@model), @model.to_sgid
    assert_equal PersonModel.build_signed_global_id(1), @model.to_signed_global_id
  end

  test 'creates a signed Global ID with purpose ' do
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_signed_global_id(for: 'login')
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_sgid(for: 'login')
    assert_equal PersonModel.build_signed_global_id(@model, for: 'login'), @model.to_sgid(for: 'login')
    assert_equal PersonModel.build_signed_global_id(1, for: 'login'), @model.to_signed_global_id(for: 'login')
  end

  test 'creates a signed Global ID with custom params' do
    assert_equal SignedGlobalID.create(@model, some: 'param'), @model.to_signed_global_id(some: 'param')
    assert_equal SignedGlobalID.create(@model, some: 'param'), @model.to_sgid(some: 'param')
    assert_equal PersonModel.build_signed_global_id(@model, some: 'param'), @model.to_sgid(some: 'param')
    assert_equal PersonModel.build_signed_global_id(1, some: 'param'), @model.to_signed_global_id(some: 'param')
  end

  test 'creates a signed Global ID with a custom app' do
    model = CustomAppPersonModel.new id: 1

    assert_equal SignedGlobalID.create(model, app: 'custom-app').to_s, model.to_signed_global_id.to_s
    assert_equal SignedGlobalID.create(model, app: 'custom-app').to_s, model.to_sgid.to_s
    assert_equal SignedGlobalID.create(model, app: 'custom-app'), CustomAppPersonModel.build_signed_global_id(1)
  end

  test "doesn't create a Global ID if ID is not valid" do
    assert_raises(ArgumentError) { PersonModel.build_global_id(PersonModel) }
    assert_raises(ArgumentError) { PersonModel.build_signed_global_id(PersonModel) }
  end

  test 'dup should clear memoized to_global_id' do
    global_id = @model.to_global_id
    dup_model = @model.dup
    dup_model.id = @model.id + 1
    dup_global_id = dup_model.to_global_id
    assert_not_equal global_id, dup_global_id
  end
end

class CustomAppPersonModel < PersonModel
  self.global_id_app = 'custom-app'
end

class OverriddenToGlobalIDPersonModel < PersonModel
  def to_global_id(options = {})
    super(options.merge(app: 'override-app'))
  end
end
