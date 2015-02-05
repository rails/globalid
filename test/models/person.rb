class Person
  include GlobalID::Identification

  attr_reader :id

  def self.find(*args)
    if args.first == :all
      args.from(1).flatten.collect { |id| new(id) }
    else
      new(args.first)
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
