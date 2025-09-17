require 'active_model'

class ConfigurableKeyModel
  include ActiveModel::Model
  include GlobalID::Identification

  attr_accessor :id, :external_id

  global_id_column :external_id

  class << self
    def primary_key
      :id
    end

    def find(_id)
      raise ".find is not supported for ConfigurableKeyModel"
    end

    def find_by(external_id:)
      new external_id: external_id, id: "id-value"
    end
  end

  def ==(other)
    external_id == other.try(:external_id)
  end
end
