require 'helper'
require 'active_model/global_identification'

require 'models/person'

Person.send :include, ActiveModel::GlobalIdentification

class GlobalIDTest < ActiveSupport::TestCase
  setup do
    @person = Person.new(5)
  end
  
  test 'global id' do
    @person.global_id.tap do |global_id|
      assert_equal Person, global_id.model_class
      assert_equal '5', global_id.model_id
    end
  end
end
