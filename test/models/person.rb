class Person
  include GlobalID::Identification

  attr_reader :id

  def self.find(id)
    new(id)
  end
  
  def self.all(ids)
    ids.collect { |id| new(id) }
  end

  def initialize(id = 1)
    @id = id
  end

  def ==(other)
    other.is_a?(self.class) && id == other.try(:id)
  end
end

class Person::Child < Person; end
