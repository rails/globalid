class Person
  include GlobalID::Identification

  attr_reader :id

  def self.find(id_or_ids)
    if id_or_ids.is_a? Array
      ids = id_or_ids
      ids.collect { |id| new(id) }
    else
      id = id_or_ids
      new(id)
    end
  end

  def initialize(id = 1)
    @id = id
  end

  def ==(other)
    other.is_a?(self.class) && id == other.try(:id)
  end
end

class Person::Child < Person; end
