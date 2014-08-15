require 'global_id'
require 'active_support/message_verifier'

class SignedGlobalID < GlobalID
  class << self
    attr_accessor :verifier
  end

  def self.parse(sgid)
    sgid.is_a?(self) ? sgid : super(verifier.verify(sgid))
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def to_s
    @sgid ||= self.class.verifier.generate(super)
  end
end
