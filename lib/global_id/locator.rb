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
        if gid = GlobalID.parse(gid)
          locator_for(gid).locate gid if find_allowed?(gid.model_class, options[:only])
        end
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

      # Tie a locator to an app.
      # Useful when different apps collaborate and reference each others' Global IDs.
      #
      # The locator can be either a block or a class.
      #
      # Using a block:
      #
      #   GlobalID::Locator.use :foo do |gid|
      #     FooRemote.const_get(gid.model_name).find(gid.model_id)
      #   end
      #
      # Using a class:
      #
      #   GlobalID::Locator.use :bar, BarLocator.new
      #
      #   class BarLocator
      #     def locate(gid)
      #       @search_client.search name: gid.model_name, id: gid.model_id
      #     end
      #   end
      def use(app, locator = nil, &locator_block)
        raise ArgumentError, 'No locator provided. Pass a block or an object that responds to #locate.' unless locator || block_given?

        GlobalID.validate_app(app)

        @locators[normalize_app(app)] = locator || BlockLocator.new(locator_block)
      end

      private
        def locator_for(gid)
          @locators.fetch(normalize_app(gid.app)) { default_locator }
        end

        def find_allowed?(model_class, only = nil)
          only ? Array(only).any? { |c| model_class <= c } : true
        end

        def normalize_app(app)
          app.to_s.downcase
        end
    end

    private
      @locators = {}

      class ActiveRecordFinder
        def locate(gid)
          gid.model_class.find gid.model_id
        end
      end

      mattr_reader(:default_locator) { ActiveRecordFinder.new }

      class BlockLocator
        def initialize(block)
          @locator = block
        end

        def locate(gid)
          @locator.call(gid)
        end
      end
  end
end
