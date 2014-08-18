class GlobalID
  module Locator
    class << self
      # Takes either a GlobalID or a string that can be turned into a GlobalID
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  If +gid+ references a class or module other than those
      #   given, +nil+ will be returned.
      def locate(gid, options = {})
        GlobalID.find gid, options
      end

      # Takes either a SignedGlobalID or a string that can be turned into a SignedGlobalID
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  If +sgid+ references a class or module other than those
      #   given, +nil+ will be returned.
      def locate_signed(sgid, options = {})
        SignedGlobalID.find sgid, options
      end
    end
  end
end
