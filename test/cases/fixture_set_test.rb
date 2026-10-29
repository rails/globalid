# frozen_string_literal: true
require 'helper'
require 'global_id/fixture_set'

class FixtureSetTest < ActiveSupport::TestCase
  class FixtureSet
    extend GlobalID::FixtureSet

    def self.identify(label, column_type)
      label.to_s.sum
    end

    def self.default_fixture_model_name(fixture_set_name)
      fixture_set_name.singularize.camelize
    end
  end

  setup do
    @use_polymorphic_name = URI::GID.use_polymorphic_name
  end

  teardown do
    URI::GID.use_polymorphic_name = @use_polymorphic_name
  end

  test 'global_id names the model like its records' do
    assert_equal 'gid://bcx/OldPerson/520', FixtureSet.global_id('old_people', :david).to_s

    URI::GID.use_polymorphic_name = true
    assert_equal 'gid://bcx/Worker/520', FixtureSet.global_id('employees', :david).to_s
    assert_equal Employee.new(520).to_gid, FixtureSet.global_id('employees', :david)
    assert_equal 'gid://bcx/Nonexistent/520', FixtureSet.global_id('nonexistents', :david).to_s
  end
end
