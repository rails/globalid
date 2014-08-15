autoload :GlobalID, 'global_id/global_id'
autoload :SignedGlobalID, 'global_id/signed_global_id'

# Active Model load hook
require 'active_support'
ActiveSupport.on_load :active_model do
  require 'active_model/global_id'
end
