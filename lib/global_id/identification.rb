require 'active_support/concern'
require 'active_support/deprecation'

class GlobalID
  module Identification
    extend ActiveSupport::Concern

    def to_global_id
      @global_id ||= GlobalID.create(self)
    end
    alias to_gid to_global_id

    def to_signed_global_id(options = {})
      @signed_global_id ||= SignedGlobalID.create(self, options)
    end
    alias to_sgid to_signed_global_id

    private
      DEPRECATED_ALIASES = {
        gid: :to_gid,
        sgid: :to_sgid,
        global_id: :to_global_id,
        signed_global_id: :to_signed_global_id
      }.freeze

      def method_missing(name, *args, &block)
        super
      rescue NoMethodError => e
        if name == e.name && DEPRECATED_ALIASES.keys.include?(name)
          new_name = DEPRECATED_ALIASES[name]
          ActiveSupport::Deprecation.warn "`#{name}` is deprecate and will be removed soon. Use `#{new_name}` instead."
          public_send(new_name, *args)
        else
          raise
        end
      end

      def respond_to_missing?(name, include_private = false)
        DEPRECATED_ALIASES.keys.include?(name) || super
      end
  end
end
