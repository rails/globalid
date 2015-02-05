require 'active_support'
require 'active_support/core_ext/enumerable' # For Enumerable#index_by

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

      # Takes an array of GlobalIDs or strings that can be turned into a GlobalIDs.
      # The GlobalIDs are located using Model.find(array_of_ids), so the models must respond to
      # that finder signature.
      #
      # This approach will efficiently call only one #find per model class, but still interpolate
      # the results to match the order in which the gids were passed.
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      def locate_many(gids, options = {})
        if (allowed_gids = parse_allowed(gids, options[:only])).any?
          models_and_ids  = allowed_gids.collect { |gid| [ gid.model_name.constantize, gid.model_id ] }
          ids_by_model    = models_and_ids.group_by(&:first)
          loaded_by_model = Hash[ids_by_model.map { |model, ids| [ model, model.find(ids.map(&:last)).index_by { |record| record.id.to_s } ] }]

          models_and_ids.collect { |(model, id)| loaded_by_model[model][id] }.compact
        else
          []
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

      # Takes an array of SignedGlobalIDs or strings that can be turned into a SignedGlobalIDs.
      # The SignedGlobalIDs are located using Model.find(array_of_ids), so the models must respond to
      # that finder signature.
      #
      # This approach will efficiently call only one #find per model class, but still interpolate
      # the results to match the order in which the gids were passed.
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      def locate_many_signed(sgids, options = {})
        locate_many sgids.collect { |sgid| SignedGlobalID.parse(sgid) }, options
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

        URI::GID.validate_app(app)

        @locators[normalize_app(app)] = locator || BlockLocator.new(locator_block)
      end

      private
        def locator_for(gid)
          @locators.fetch(normalize_app(gid.app)) { default_locator }
        end

        def find_allowed?(model_class, only = nil)
          only ? Array(only).any? { |c| model_class <= c } : true
        end

        def parse_allowed(gids, only = nil)
          gids.collect { |gid| GlobalID.parse(gid) }.compact.select { |gid| find_allowed?(gid.model_class, only) }
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
