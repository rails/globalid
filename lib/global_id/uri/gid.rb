module URI
  class GID < Generic
    def self.create(app, model)
      URI("gid://#{app}/#{model.class.name}/#{model.id}")
    end

    def self.parse(string)
      URI.parse(string).tap do |uri|
        raise URI::BadURIError, "Not a gid:// URI scheme: #{uri.inspect}" unless uri.is_a?(self)
      end
    end

    def app
      host
    end

    def model_name
      path.split('/')[1]
    end

    def model_id
      path.split('/')[2]
    end
  end

  @@schemes['GID'] = GID
end
