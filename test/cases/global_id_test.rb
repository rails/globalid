require 'helper'
require 'active_model/global_id'

require 'models/person'

class GlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_gid = ActiveModel::GlobalID.create(Person.new(5))
  end
  
  test 'string representation' do
    assert_equal 'GlobalID-Person-5', @person_gid.to_s
  end
  
  test 'model id' do
    assert_equal "5", @person_gid.model_id
  end

  test 'model class' do
    assert_equal Person, @person_gid.model_class
  end
  
  test 'global ids are values' do
    assert_equal ActiveModel::GlobalID.create(Person.new(5)), ActiveModel::GlobalID.create(Person.new(5))
  end
end
