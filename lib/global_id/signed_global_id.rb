require 'global_id'
require 'active_support/message_verifier'

class SignedGlobalID < GlobalID
  class << self
    attr_accessor :verifier

    def parse(sgid, options = {})
      if sgid.is_a? self
        sgid
      else
        super verify(sgid, pick_verifier(options))
      end
    end

    # Grab the verifier from options and fall back to SignedGlobalID.verifier.
    # Raise ArgumentError if neither is available.
    def pick_verifier(options)
      options.fetch :verifier do
        verifier || raise(ArgumentError, 'Pass a `verifier:` option with an `ActiveSupport::MessageVerifier` instance, or set a default SignedGlobalID.verifier.')
      end
    end

    private
      def verify(sgid, verifier)
        verifier.verify(sgid)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        nil
      end
  end

  attr_reader :verifier

  def initialize(gid, options = {})
    super
    @verifier = self.class.pick_verifier(options)
  end

  def to_s
    @sgid ||= @verifier.generate(super)
  end
  alias to_param to_s
end
