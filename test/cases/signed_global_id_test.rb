require 'helper'
require 'active_model/signed_global_id'

require 'models/person'

ActiveModel::SignedGlobalID.verifier = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN')

class SignedGlobalIDTest < ActiveSupport::TestCase
  setup do
    @person_sgid = ActiveModel::SignedGlobalID.create(Person.new(5))
  end
  
  test 'string representation' do
    assert_equal 'BAhJIhZHbG9iYWxJRC1QZXJzb24tNQY6BkVU--391ec38a7b004f46caa1acd75bb0f5078e91b4ea', @person_sgid.to_s
  end
  
  test 'model id' do
    assert_equal "5", @person_sgid.model_id
  end

  test 'model class' do
    assert_equal Person, @person_sgid.model_class
  end
end
