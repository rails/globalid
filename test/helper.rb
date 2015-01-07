require 'bundler/setup'
require 'active_support'
require 'active_support/testing/autorun'

require 'global_id'
require 'models/person'
require 'models/person_model'

require 'json'

if ActiveSupport::TestCase.respond_to?(:test_order)
  # TODO: remove check once ActiveSupport depencency is at least 4.2
  ActiveSupport::TestCase.test_order = :random
end

GlobalID.app = 'bcx'

# Default serializers is Marshal, whose format changed 1.9 -> 2.0,
# so use a trivial serializer for our tests.
SERIALIZER = JSON

VERIFIER = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN', serializer: SERIALIZER)
SignedGlobalID.verifier = VERIFIER
