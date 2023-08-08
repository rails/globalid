require 'active_support/message_verifier'

class GlobalID
  class Verifier < ActiveSupport::MessageVerifier
    private
      def sign_encoded(data)
        ::Base64.urlsafe_encode64(data)
      end

      def extract_encoded(data)
        ::Base64.urlsafe_decode64(data)
      end
  end
end
