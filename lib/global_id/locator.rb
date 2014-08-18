class GlobalID
  module Locator
    class << self
      # Takes either a GlobalID or a string that can be turned into a GlobalID
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      def locate(gid, options = {})
        GlobalID.find gid, options
      end

      # Takes either a SignedGlobalID or a string that can be turned into a SignedGlobalID
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      def locate_signed(sgid, options = {})
        SignedGlobalID.find sgid, options
      end
    end
  end
end
