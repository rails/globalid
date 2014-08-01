begin
require 'rails/railtie'
rescue LoadError
else

module ActiveModel
  # Set up the signed GlobalID verifier and include Active Record support for
  # #global_id and #signed_global_id.
  class Railtie < Rails::Railtie # :nodoc:
    initializer "active_model.globalid" do
      ActiveModel::GlobalID.app = Rails.application.railtie_name.remove('_application')

      config.after_initialize do |app|
        ActiveModel::SignedGlobalID.verifier = app.message_verifier(:signed_global_ids)
      end

      ActiveSupport.on_load(:active_record) do
        require 'active_model/global_identification'
        send :include, ActiveModel::GlobalIdentification
      end
    end
  end
end

end
