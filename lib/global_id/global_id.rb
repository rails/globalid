require 'active_support'
require 'active_support/core_ext/string/inflections'  # For #model_class constantize
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/object/try'          # For #find
require 'uri'
require 'global_id/uri/gid'

class GlobalID
  class << self
    attr_accessor :app

    def create(model)
      new URI::GID.create(GlobalID.app, model)
    end

    def find(gid)
      parse(gid).try :find
    end

    def parse(gid)
      gid.is_a?(self) ? gid : new(gid)
    rescue URI::Error
      nil
    end
  end

  attr_reader :uri, :app, :model_name, :model_id

  def initialize(gid)
    extract_uri_components gid
  end

  def find
    model_class.find model_id
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

  private
    def extract_uri_components(gid)
      @uri = gid.is_a?(URI) ? gid : URI::GID.parse(gid)

      @app = @uri.app
      @model_name = @uri.model_name
      @model_id = @uri.model_id
    end
end
