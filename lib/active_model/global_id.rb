require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/object/try'
require 'uri'

module ActiveModel
  autoload :GlobalLocator,  'active_model/global_locator'
  autoload :SignedGlobalID, 'active_model/signed_global_id'

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
      @app = @uri.host
      @model_name, @model_id = @uri.path.split('/')[1, 2]
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
  end
end
