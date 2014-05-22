class Person
  attr_reader :id
  
  def self.find(id)
    new(id)
  end
  
  def initialize(id)
    @id = id
  end
end

class Person::Child < Person; end