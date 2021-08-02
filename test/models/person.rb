require 'pry'

class Person
  include GlobalID::Identification

  HARDCODED_ID_FOR_MISSING_PERSON = '1000'

  attr_reader :id

  def self.find(id_or_ids)
    if id_or_ids.is_a? Array
      ids = id_or_ids
      ids.collect { |id| find(id) }
    else
      id = id_or_ids

      if id == HARDCODED_ID_FOR_MISSING_PERSON
        raise 'Person missing'
      else
        new(id: id)
      end
    end
  end

  def self.find_by(args)
    find_by_options = args.with_indifferent_access
    if find_by_options[:id].present? && find_by_options[:id] == HARDCODED_ID_FOR_MISSING_PERSON
      raise 'Person missing'
    else
      new(find_by_options)
    end
  end

  def self.where(conditions)
    (conditions[:id] - [HARDCODED_ID_FOR_MISSING_PERSON]).collect { |id| new(id: id) }
  end

  def initialize(**args)
    args.each do |k, v|
      define_singleton_method(k) { v }
    end
  end

  def ==(other)
    other.is_a?(self.class) && id == other.try(:id)
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

class Person::Child < Person; end
