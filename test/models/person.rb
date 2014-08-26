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

module UnixGroupMember
  def gid
    'group ID'
  end
end

class UnixUser < Person
  include UnixGroupMember

  def sgid
    'set group ID'
  end

  # Some version of Active Record uses method missing to define attribute
  # methods
  def method_missing(name, *args, &block)
    if name == :global_id
      'global_id'
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    (name == :global_id) || super
  end
end
