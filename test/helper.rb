require 'bundler/setup'
require 'active_support'
require 'active_support/testing/autorun'

require 'global_id'
require 'models/person'
require 'models/person_model'

GlobalID.app = 'bcx'

# Default serializers is Marshal, whose format changed 1.9 -> 2.0,
# so use a trivial serializer for our tests.
class StringSerializer
  def dump(gid) gid.to_s end
  def load(data) data end
end

VERIFIER = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN', serializer: StringSerializer.new)
SignedGlobalID.verifier = VERIFIER
