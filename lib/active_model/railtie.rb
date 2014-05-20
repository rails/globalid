require 'active_model/global_identification'

module ActiveModel
  class Railtie < Rails::Railtie
    initializer "active_model.globalid" do
      config.after_initialize do |app|
        ActiveModel::SignedGlobalID.verifier = Rails.application.message_verifier(:signed_global_ids)
      end

      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, ActiveModel::GlobalIdentification
      end
    end
  end
end

