class Person
  include GlobalID::Identification

  attr_reader :id

  def self.find(id)
    new(id)
  end

  def initialize(id = 1)
    @id = id
  end

  def ==(other)
    id == other.try(:id)
  end
end

class Person::Child < Person; end
