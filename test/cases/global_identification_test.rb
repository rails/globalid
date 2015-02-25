require 'helper'

class GlobalIdentificationTest < ActiveSupport::TestCase
  setup do
    @model = PersonModel.new id: 1
    @user = User.create(name: "Abidik Gubidik")
    @post = Post.create(name: "Sample Post", user: @user)
  end

  test 'creates a Global ID from self' do
    assert_equal GlobalID.create(@model), @model.to_global_id
    assert_equal GlobalID.create(@model), @model.to_gid
  end

  test 'creates a signed Global ID from self' do
    assert_equal SignedGlobalID.create(@model), @model.to_signed_global_id
    assert_equal SignedGlobalID.create(@model), @model.to_sgid
  end

  test 'creates a signed Global ID with purpose ' do
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_signed_global_id(for: 'login')
    assert_equal SignedGlobalID.create(@model, for: 'login'), @model.to_sgid(for: 'login')
  end

  test 'object.relation_gid & object.relation_global_id methods' do
    assert_equal @post.user_gid, @user.to_gid
    assert_equal @post.user_global_id, @user.to_gid
  end

  test 'object.relation_sgid & object.relation_signed_global_id methods' do
    assert_equal @post.user_sgid, @user.to_sgid
    assert_equal @post.user_signed_global_id, @user.to_sgid
  end
end
