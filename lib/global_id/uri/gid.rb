require 'uri/generic'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'

module URI
  class GID < Generic
    # URI::GID encodes an app unique reference to a specific model as an URI.
    # It has three components: the app name, the model's class name and the
    # model's id.
    # The URI format looks like "gid://app/model_name/model_id".
    #
    # Read the documentation for +parse+, +create+ and +build+ for more.
    alias :app :host
    attr_reader :model_name, :model_id

    class << self
      # Validates +app+'s as URI hostnames containing only alphanumeric characters
      # and hyphens. An ArgumentError is raised if +app+ is invalid.
      #
      #   URI::GID.validate_app('bcx')     # => 'bcx'
      #   URI::GID.validate_app('foo-bar') # => 'foo-bar'
      #
      #   URI::GID.validate_app(nil)       # => ArgumentError
      #   URI::GID.validate_app('foo/bar') # => ArgumentError
      def validate_app(app)
        parse("gid://#{app}/Model/1").app
      rescue URI::Error
        raise ArgumentError, 'Invalid app name. ' \
          'App names must be valid URI hostnames: alphanumeric and hyphen characters only.'
      end

      # Create a new URI::GID by parsing a gid string with argument check.
      #
      #   URI::GID.parse 'gid://bcx/Person/1'
      #
      # This differs from URI() and URI.parse which do not check arguments.
      #
      #   URI('gid://bcx')             # => URI::GID instance
      #   URI.parse('gid://bcx')       # => URI::GID instance
      #   URI::GID.parse('gid://bcx/') # => raises URI::InvalidComponentError
      def parse(uri)
        generic_components = URI.split(uri) << nil << true # nil parser, true arg_check
        new *generic_components
      end

      # Shorthand to build a URI::GID from and app and a model.
      #
      #   URI::GID.create('bcx', Person.find(5))
      def create(app, model)
        build app: app, model_name: model.class.name, model_id: model.id
      end

      # Create a new URI::GID from components with argument check.
      #
      # The allowed components are app, model_name and model_id, which can be
      # either a hash or an array.
      #
      # Using a hash:
      #
      #   URI::GID.build(app: 'bcx', model_name: 'Person', model_id: '1')
      #
      # Using an array, the arguments must be in order [app, model_name, model_id]:
      #
      #   URI::GID.build(['bcx', 'Person', '1'])
      def build(args)
        parts = Util.make_components_hash(self, args)
        parts[:host] = parts[:app]
        parts[:path] = "/#{parts[:model_name]}/#{parts[:model_id]}"

        super parts
      end
    end

    def to_s
      # Implement #to_s to avoid no implicit conversion of nil into string when path is nil
      "gid://#{app}/#{model_name}/#{model_id}"
    end

    protected
      def set_path(path)
        set_model_components(path) unless @model_name && @model_id
        super
      end

    private
      COMPONENT = [ :scheme, :app, :model_name, :model_id ].freeze

      # Extracts model_name and model_id from the URI path.
      PATH_REGEXP = %r(\A/([^/]+)/?([^/]+)?\z)

      def check_host(host)
        validate_component(host)
        super
      end

      def check_path(path)
        validate_component(path)
        set_model_components(path, true)
      end

      def check_scheme(scheme)
        if scheme == 'gid'
          super
        else
          raise URI::BadURIError, "Not a gid:// URI scheme: #{inspect}"
        end
      end

      def set_model_components(path, validate = false)
        _, model_name, model_id = path.match(PATH_REGEXP).to_a

        validate_component(model_name) && validate_component(model_id) if validate

        @model_name = model_name
        @model_id = model_id
      end

      def validate_component(component)
        return component unless component.blank?

        raise URI::InvalidComponentError,
          "Expected a URI like gid://app/Person/1234: #{inspect}"
      end
  end

  @@schemes['GID'] = GID
end
