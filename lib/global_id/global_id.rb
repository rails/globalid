require 'active_support'
require 'active_support/core_ext/string/inflections'  # For #model_class constantize
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/object/try'          # For #find
require 'uri'

class GlobalID
  class << self
    attr_accessor :app

    def create(model)
      new URI("gid://#{GlobalID.app}/#{model.class.name}/#{model.id}")
    end

    def find(gid)
      parse(gid).try :find
    end

    def parse(gid)
      gid.is_a?(self) ? gid : new(gid)
    rescue URI::InvalidURIError
      nil
    end
  end

  attr_reader :uri, :app, :model_name, :model_id

  def initialize(gid)
    @uri = gid.is_a?(URI) ? gid : URI.parse(gid)
    @app, @model_name, @model_id = extract_uri_components(@uri)
  end

  def find
    model_class.find model_id
  end

  def model_class
    model_name.constantize
  end

  def ==(other)
    other.is_a?(GlobalID) && uri == other.uri
  end

  def to_s
    uri.to_s
  end

  private
    PATH_REGEXP = %r(\A/([^/]+)/([^/]+)\z)

    # Pending a URI::GID to handle validation
    def extract_uri_components(uri)
      raise ArgumentError, "Not a gid:// URI scheme: #{uri.inspect}" unless @uri.scheme == 'gid'
      raise ArgumentError, "Missing app name: #{uri.inspect}" unless @uri.host

      if @uri.path =~ PATH_REGEXP
        [ @uri.host, $1, $2 ]
      else
        raise ArgumentError, "Expected a /Model/id URI path: #{uri.inspect}"
      end
    end
end
