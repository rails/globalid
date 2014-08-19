require 'global_id'
require 'active_support/message_verifier'

class SignedGlobalID < GlobalID
  class << self
    attr_accessor :verifier
  end

  def self.create(model, options = {})
    self.verifier ||= options[:verifier]
    with_present_verifier { super }
  end

  def self.parse(sgid)
    sgid.is_a?(self) ? sgid : with_present_verifier { super(verifier.verify(sgid)) }
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def self.with_present_verifier(&block)
    raise ArgumentError, "#{name}.verifier is nil. Set a verifier on #{name}" unless verifier
    block.call
  end
  private_class_method :with_present_verifier

  def to_s
    @sgid ||= self.class.verifier.generate(super)
  end
  alias to_param to_s
end
