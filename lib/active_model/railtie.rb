require 'active_model/global_identification'

ActiveModel::SignedGlobalID.verifier = Rails.application.message_verifier(:signed_global_ids)

ActiveRecord::Base.send :include, ActiveModel::GlobalIdentification
