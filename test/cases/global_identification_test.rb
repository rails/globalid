require 'helper'
require 'models/person'

Person.send :include, GlobalID::Identification

class GlobalIDTest < ActiveSupport::TestCase
  test 'global id' do
    @person = Person.new(5)
    @person.global_id.tap do |global_id|
      assert_equal Person, global_id.model_class
      assert_equal '5', global_id.model_id
    end
  end

  test 'global id (uuid)' do
    @person = Person.new('7ef9b614-353c-43a1-a203-ab2307851990')
    @person.global_id.tap do |global_id|
      assert_equal Person, global_id.model_class
      assert_equal '7ef9b614-353c-43a1-a203-ab2307851990', global_id.model_id
    end
  end

  test 'global id (string)' do
    @person = Person.new('foobar')
    @person.global_id.tap do |global_id|
      assert_equal Person, global_id.model_class
      assert_equal 'foobar', global_id.model_id
    end
  end
end
