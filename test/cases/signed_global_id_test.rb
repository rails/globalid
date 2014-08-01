require 'helper'
require 'active_model/signed_global_id'

require 'models/person'

ActiveModel::SignedGlobalID.verifier = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN')

class SignedGlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_sgid = ActiveModel::SignedGlobalID.create(Person.new(5))
  end

  test 'string representation' do
    assert_equal 'BAhJIhdnaWQ6Ly9iY3gvUGVyc29uLzUGOgZFVA==--c89e90838414d1fee59545b1bd85cfd400ea3362', @person_sgid.to_s
  end

  test 'model id' do
    assert_equal "5", @person_sgid.model_id
  end

  test 'model class' do
    assert_equal Person, @person_sgid.model_class
  end

  test 'value equality' do
    assert_equal ActiveModel::SignedGlobalID.create(Person.new(5)), ActiveModel::SignedGlobalID.create(Person.new(5))
  end

  test 'value equality with an unsigned id' do
    assert_equal ActiveModel::GlobalID.create(Person.new(5)), ActiveModel::SignedGlobalID.create(Person.new(5))
  end
end
