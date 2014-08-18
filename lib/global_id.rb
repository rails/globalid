require 'global_id/global_id'
require 'global_id/scheme'
autoload :SignedGlobalID, 'global_id/signed_global_id'

class GlobalID
  autoload :Locator, 'global_id/locator'
  autoload :Identification, 'global_id/identification'
end
