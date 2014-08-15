require 'bundler/setup'
require 'active_support'
require 'active_support/testing/autorun'

require 'global_id'
require 'models/person'

GlobalID.app = 'bcx'

SignedGlobalID.verifier = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN')
