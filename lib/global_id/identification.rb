class GlobalID
  module Identification
    def to_global_id(options = {})
      GlobalID.create(self, options)
    end
    alias to_gid to_global_id

    def to_gid_param(options = {})
      to_global_id(options).to_param
    end

    def to_signed_global_id(options = {})
      SignedGlobalID.create(self, options)
    end
    alias to_sgid to_signed_global_id

    def to_sgid_param(options = {})
      to_signed_global_id(options).to_param
    end
  end
end
