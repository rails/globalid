module ActiveModel
  class GlobalLocator
    class << self
      # Takes either a GlobalID or a string that can be turned into a GlobalID
      def locate(gid)
        GlobalID.find gid
      end

      # Takes either a SignedGlobalID or a string that can be turned into a SignedGlobalID
      def locate_signed(sgid)
        SignedGlobalID.find sgid
      end
    end
  end
end
