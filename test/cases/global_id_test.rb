require 'helper'
require 'active_model/global_id'

require 'models/person'

class GlobalIDTest < ActiveSupport::TestCase
  setup do
    @uuid = '7ef9b614-353c-43a1-a203-ab2307851990'
    @person_gid = ActiveModel::GlobalID.create(Person.new(5))
    @person2_gid = ActiveModel::GlobalID.create(Person.new(@uuid))
  end

  test 'string representation' do
    assert_equal 'GlobalID-Person-5', @person_gid.to_s
  end

  test 'string representation (uuid)' do
    assert_equal "GlobalID-Person-#{@uuid}", @person2_gid.to_s
  end

  test 'model id' do
    assert_equal @uuid, @person2_gid.model_id
  end

  test 'model id (uuid)' do
    assert_equal @uuid, @person2_gid.model_id
  end

  test 'model class' do
    assert_equal Person, @person_gid.model_class
  end

  test 'model class (uuid)' do
    assert_equal Person, @person2_gid.model_class
  end

  test 'global ids are values' do
    assert_equal ActiveModel::GlobalID.create(Person.new(5)), ActiveModel::GlobalID.create(Person.new(5))
  end

  test 'global ids are values (uuid)' do
    assert_equal ActiveModel::GlobalID.create(Person.new(@uuid)), ActiveModel::GlobalID.create(Person.new(@uuid))
  end
end
