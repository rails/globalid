module ActiveModel
  class SignedGlobalID < GlobalID
    class << self
      attr_accessor :verifier
    end

    def self.create(model)
      new verifier.generate("GlobalID-#{model.class.name}-#{model.id}")
    end

    def initialize(sgid)
      @gid = self.class.verifier.verify(sgid)
    end
  
    def ==(other_global_id)
      other_global_id.is_a?(SignedGlobalID) && to_s == other_global_id.to_s
    end

    def to_s
      @sgid ||= self.class.verifier.generate(@gid)
    end
  end
end
