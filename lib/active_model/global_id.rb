require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/access'

module ActiveModel
  class GlobalID
    def self.create(model)
      new "GlobalID-#{model.class.name}-#{model.id}"
    end

    def initialize(gid)
      @gid = gid
    end

    def model_class
      @model_klass ||= @gid.split("-").second.constantize
    end

    def model_id
      @model_id ||= @gid.split("-").third
    end

    def ==(other_global_id)
      other_global_id.is_a?(GlobalID) && to_s == other_global_id.to_s
    end

    def to_s
      @gid
    end
  end
end
