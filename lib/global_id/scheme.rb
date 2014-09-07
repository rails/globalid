require 'uri/generic'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'

module URI
  class GlobalID < Generic

    COMPONENT = [ :scheme, :app, :model_name, :model_id ].freeze

    PATH_REGEXP = %r(\A/([^/]+)/?([^/]+)?\z)

    attr_reader :app, :model_name, :model_id

    def self.create(app, model)
      parse("gid://#{app}/#{model.class.name}/#{model.id}")
    end

    def self.parse(uri)
      uri_components = URI.split(uri)
      build(*uri_components)
    end

    def self.build(*args)
      args << nil   # parser
      args << true  # arg_check

      new(*args)
    end

    def initialize(*args)
      @arg_check = args[10]
      args[10] = validate_components?

      super(*args)

      _, model_name, model_id = *(@path.match(PATH_REGEXP))

      self.app = @host
      self.model_name = model_name
      self.model_id = model_id
    end

    def app=(value)
      validate_component(value) if validate_components?
      check_host(value) if validate_components?
      @app = value
    end

    def model_name=(value)
      validate_component(value) if validate_components?
      @model_name = value
    end

    def model_id=(value)
      validate_component(value) if validate_components?
      @model_id = value
    end

    def to_s
      "#{scheme}://#{app}/#{model_name}/#{model_id}"
    end

    private

      def validate_components?
        return false if @arg_check == false
        true
      end

      def validate_component(component)
        if component.blank?
          raise URI::InvalidComponentError,
                "Expected a URI like gid://app/Person/1234: #{self.inspect}"
        end
      end

      def check_scheme(value)
        super(value)

        if value != 'gid'
          raise URI::BadURIError, "Not a gid:// URI scheme: #{self.inspect}"
        end
      end
  end

  @@schemes['GID'] =  GlobalID
end
