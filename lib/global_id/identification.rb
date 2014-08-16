require 'active_support/concern'

class GlobalID
  module Identification
    extend ActiveSupport::Concern

    def global_id
      @global_id ||= GlobalID.create(self)
    end
    alias gid global_id

    def signed_global_id
      @signed_global_id ||= SignedGlobalID.create(self)
    end
    alias sgid signed_global_id
  end
end
