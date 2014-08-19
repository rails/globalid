require 'active_support'
require 'active_support/core_ext/string/inflections'  # For #model_class constantize
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/object/try'          # For #find
require 'uri'

class GlobalID
  class << self
    attr_reader :app

    def create(model, options = {})
      app = options.fetch :app, GlobalID.app
      raise ArgumentError, "An app is required to create a GlobalID. Pass the :app option or set the default GlobalID.app." unless app
      new URI("gid://#{app}/#{model.class.name}/#{model.id}"), options
    end

    def find(gid, options = {})
      parse(gid, options).try(:find, options)
    end

    def parse(gid, options = {})
      gid.is_a?(self) ? gid : new(gid, options)
    rescue URI::Error
      parse_encoded_gid(gid, options)
    end

    def app=(app)
      @app = validate_app(app)
    end

    def validate_app(app)
      URI.parse('gid:///').hostname = app
    rescue URI::InvalidComponentError
      raise ArgumentError, 'Invalid app name. ' \
        'App names must be valid URI hostnames: alphanumeric and hyphen characters only.'
    end

    private
      def parse_encoded_gid(gid, options)
        new(Base64.urlsafe_decode64(repad_gid(gid)), options) rescue nil
      end

      # We removed the base64 padding character = during #to_param, now we're adding it back so decoding will work
      def repad_gid(gid)
        padding_chars = gid.length.modulo(4).zero? ? 0 : (4 - gid.length.modulo(4))
        gid + ('=' * padding_chars)
      end
  end

  attr_reader :uri, :app, :model_name, :model_id

  def initialize(gid, options = {})
    extract_uri_components gid
  end

  def find(options = {})
    Locator.locate self, options
  end

  def model_class
    model_name.constantize
  end

  def ==(other)
    other.is_a?(GlobalID) && @uri == other.uri
  end

  def to_s
    @uri.to_s
  end

  def to_param
    # remove the = padding character for a prettier param -- it'll be added back in parse_encoded_gid
    Base64.urlsafe_encode64(to_s).sub(/=+$/, '')
  end

  private
    PATH_REGEXP = %r(\A/([^/]+)/([^/]+)\z)

    # Pending a URI::GID to handle validation
    def extract_uri_components(gid)
      @uri = gid.is_a?(URI) ? gid : URI.parse(gid)
      raise URI::BadURIError, "Not a gid:// URI scheme: #{@uri.inspect}" unless @uri.scheme == 'gid'

      if @uri.path =~ PATH_REGEXP
        @app = @uri.host
        @model_name = $1
        @model_id = $2
      else
        raise URI::InvalidURIError, "Expected a URI like gid://app/Person/1234: #{@uri.inspect}"
      end
    end
end
