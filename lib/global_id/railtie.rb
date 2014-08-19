begin
require 'rails/railtie'
rescue LoadError
else
require 'global_id'

class GlobalID
  # = GlobalID Railtie
  # Set up the signed GlobalID verifier and include Active Record support.
  class Railtie < Rails::Railtie # :nodoc:
    config.global_id = ActiveSupport::OrderedOptions.new

    initializer 'global_id' do |app|

      app.config.global_id.app ||= app.railtie_name.remove('_application')
      GlobalID.app = app.config.global_id.app

      config.after_initialize do
        app.config.global_id.verifier ||= begin
          app.message_verifier(:signed_global_ids)
        rescue ArgumentError
          nil
        end
        SignedGlobalID.verifier = app.config.global_id.verifier
      end

      ActiveSupport.on_load(:active_record) do
        require 'global_id/identification'
        send :include, GlobalID::Identification
      end
    end
  end
end

end
