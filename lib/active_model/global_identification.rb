require 'active_model/global_id'
require 'active_model/signed_global_id'

module ActiveModel
  module GlobalIdentification
    extend ActiveSupport::Concern

    def global_id
      GlobalID.create(self)
    end
    alias gid global_id

    def signed_global_id
      SignedGlobalID.create(self)
    end
    alias sgid signed_global_id
  end
end