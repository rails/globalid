require 'uri/generic'
require 'active_support/core_ext/module/aliasing'

module URI
  class GlobalID < Generic

    COMPONENT = [ :scheme, :app, :model_name, :model_id ].freeze

    PATH_REGEXP = %r(\A/([^/]+)/([^/]+)\z)

    alias_attribute :app, :host
    attr_reader :model_name, :model_id

    def initialize(scheme, userinfo, host, port, registry, path, opaque, query,
                   fragment, parser = DEFAULT_PARSER, arg_check = true)
      super(scheme, userinfo, host, port, registry, path, opaque, query,
            fragment, parser, arg_check)

      _, model_name, model_id = *(path.match(PATH_REGEXP))

      if arg_check
        self.model_name = model_name
        self.model_id = model_id
      else
        set_model_name(model_name)
        set_model_id(model_id)
      end
    end

    def model_name=(value)
      check_model_name(value)
      set_model_name(value)
      value
    end

    def model_id=(value)
      check_model_id(value)
      set_model_id(value)
      value
    end

    def to_s
      "#{@scheme}://#{@host}/#{@model_name}/#{@model_id}"
    end

    protected

    def set_model_name(value)
      @model_name = value
    end

    def set_model_id(value)
      @model_id = value
    end

    private

    def check_model_name(value)
      raise URI::InvalidComponentError, "Expected a URI like gid://app/Person/1234: #{self.inspect}" if value.nil?
    end

    def check_model_id(value)
      raise URI::InvalidComponentError, "Expected a URI like gid://app/Person/1234: #{self.inspect}" if value.nil?
    end
  end

  @@schemes['GID'] =  GlobalID
end
