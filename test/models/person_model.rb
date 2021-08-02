require 'active_model'

class PersonModel
  include ActiveModel::Model
  include GlobalID::Identification

  attr_accessor :id, :uuid

  def self.find(id)
    new id: id
  end

  def ==(other)
    id == other.try(:id)
  end
end
