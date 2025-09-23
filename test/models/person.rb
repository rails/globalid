class Person
  include GlobalID::Identification

  HARDCODED_ID_FOR_MISSING_PERSON = '1000'

  attr_reader :id

  def self.primary_key
    :id
  end

  def self.find(id_or_ids)
    if id_or_ids.is_a? Array
      ids = id_or_ids
      ids.collect { |id| find(id) }
    else
      id = id_or_ids

      if id == HARDCODED_ID_FOR_MISSING_PERSON
        raise 'Person missing'
      else
        new(id)
      end
    end
  end

  def self.where(conditions)
    (conditions[primary_key] - [HARDCODED_ID_FOR_MISSING_PERSON]).collect { |id| new(id) }
  end

  def initialize(id = 1)
    @id = id
  end

  def ==(other)
    other.is_a?(self.class) && id == other.try(:id)
  end
end

class PersonUuid < Person
  def self.primary_key
    :uuid
  end
end

class Person::Scoped < Person
  def initialize(*)
    super
    @find_allowed = false
  end

  def self.unscoped
    @find_allowed = true
    yield
  end

  def self.find(*)
    super if @find_allowed
  end
end

class Person::ChildWithParent < Person
  def self.find(id_or_ids)
    if id_or_ids.is_a? Array
      ids = id_or_ids
      ids.collect { |id| find(id) }
    else
      id = id_or_ids

      if id == HARDCODED_ID_FOR_MISSING_PERSON
        raise 'Person missing'
      else
        Person::Child.new(id, Person.new(id))
      end
    end
  end

  def self.where(conditions)
    (conditions[:id] - [HARDCODED_ID_FOR_MISSING_PERSON]).collect do |id|
      Person::Child.new(id, Person.new(id))
    end
  end
end

class Person::Child < Person
  attr_accessor :parent

  def initialize(id = 1, parent = nil)
    @id = id
    @parent = parent
  end

  def self.includes(relationships)
    return Person::ChildWithParent if relationships == :parent
    return self if relationships.nil?

    raise StandardError, 'Relationship does not exist'
  end

  def ==(other)
    other.is_a?(self.class) && id == other.try(:id) && parent == other.parent
  end
end

class PersonWithoutPrimaryKey
  include GlobalID::Identification

  attr_reader :id

  def self.find(id_or_ids)
    if id_or_ids.is_a? Array
      ids = id_or_ids
      ids.collect { |id| find(id) }
    else
      id = id_or_ids
      new(id)
    end
  end

  def self.where(conditions)
    (conditions[:id]).collect { |id| new(id) }
  end

  def initialize(id = 1)
    @id = id
  end
end
