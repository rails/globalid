begin
require 'rails/railtie'
rescue LoadError
else

module ActiveModel
  # Set up the signed GlobalID verifier and include Active Record support.
  class GlobalIDRailtie < Rails::Railtie # :nodoc:
    initializer 'active_model.global_id' do
      require 'active_model/global_id'

      # TODO: expose as app config.global_id.app = 'name'
      GlobalID.app = Rails.application.railtie_name.remove('_application')

      # TODO: expose as app config.global_id.verifier = custom_verifier
      config.after_initialize do |app|
        SignedGlobalID.verifier = app.message_verifier(:signed_global_ids)
      end

      ActiveSupport.on_load(:active_record) do
        require 'active_model/global_identification'
        send :include, ActiveModel::GlobalIdentification
      end
    end
  end
end

end
