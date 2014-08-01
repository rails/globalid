require 'bundler/setup'
require 'active_support'
require 'active_support/testing/autorun'

require 'active_model/global_id'
require 'models/person'
ActiveModel::GlobalID.app = 'bcx'
