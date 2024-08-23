require 'active_model'

class ConfigurableKeyModel
  include ActiveModel::Model
  include GlobalID::Identification

  attr_accessor :id, :external_id

  def self.primary_key
    :id
  end
end
