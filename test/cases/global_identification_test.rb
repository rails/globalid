# frozen_string_literal: true
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

  test 'creates a Global ID with a custom app' do
    model = CustomAppPersonModel.new id: 1

    assert_equal GlobalID.create(model, app: 'custom-app'), model.to_global_id
    assert_equal GlobalID.create(model, app: 'custom-app'), model.to_gid
    assert_equal GlobalID.create(model, app: 'other-app'), model.to_global_id(app: 'other-app')
  end

  test 'to_gid delegates to overridden to_global_id' do
    model = OverriddenToGlobalIDPersonModel.new id: 1

    assert_equal GlobalID.create(model, app: 'override-app'), model.to_gid
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

  test 'creates a signed Global ID with a custom app' do
    model = CustomAppPersonModel.new id: 1

    assert_equal SignedGlobalID.create(model, app: 'custom-app').to_s, model.to_signed_global_id.to_s
    assert_equal SignedGlobalID.create(model, app: 'custom-app').to_s, model.to_sgid.to_s
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
  def to_global_id(app: 'override-app', **)
    super
  end
end
