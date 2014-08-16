require 'active_model'

class PersonModel
  include ActiveModel::Model
  include GlobalID::Identification

  attr_accessor :id

  def self.find(id)
    new id: id
  end
end
