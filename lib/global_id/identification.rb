require 'active_support/concern'

class GlobalID
  module Identification
    extend ActiveSupport::Concern

    def to_global_id
      @global_id ||= GlobalID.create(self)
    end
    alias to_gid to_global_id

    def to_gid_param
      to_global_id.to_param
    end

    def to_signed_global_id(options = {})
      SignedGlobalID.create(self, options)
    end
    alias to_sgid to_signed_global_id

    def to_sgid_param(options = {})
      to_signed_global_id(options).to_param
    end

    ActiveRecord::Associations::Builder::BelongsTo.instance_eval do
      def define_accessors(model, reflection)
        class_name = reflection.options.fetch(:class_name, reflection.name.capitalize.to_s)
        foreign_key = reflection.options.fetch(:foreign_key, "#{reflection.name}_id")

        if reflection.options[:polymorphic]
          class_name = "#{reflection.name}_type"
        end

        ["#{reflection.name}_gid", "#{reflection.name}_global_id"].each do |method|
          model.send(:define_method, method) do
            GlobalID.create_from(reflection.options[:polymorphic] ? send(class_name) : class_name, send(foreign_key))
          end
        end

        ["#{reflection.name}_sgid", "#{reflection.name}_signed_global_id"].each do |method|
          model.send(:define_method, method) do
            SignedGlobalID.create_from(reflection.options[:polymorphic] ? send(class_name) : class_name, send(foreign_key))
          end
        end

        super
      end
    end

  end
end
