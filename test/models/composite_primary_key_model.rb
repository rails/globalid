require 'active_model'

class CompositePrimaryKeyModel
  include ActiveModel::Model
  include GlobalID::Identification

  attr_accessor :id

  def self.primary_key
    [:tenant_key, :id]
  end

  def self.find(id_or_ids)
    raise "id is not composite" unless id_or_ids.is_a?(Array)
    multi_record_fetch = id_or_ids.first.is_a?(Array)
    if multi_record_fetch
      id_or_ids.map do |id|
        raise "id doesn't match primary key #{primary_key}" if id.size != primary_key.size
        new id: id
      end
    else
      raise "id doesn't match primary key #{primary_key}" if id_or_ids.size != primary_key.size
      new id: id_or_ids
    end
  end

  def where(conditions)
    keys = conditions.keys
    raise "only primary key condition was expected" if keys.size != 1
    pk = keys.first
    raise "key is not the `#{primary_key}` primary key" if pk != primary_key

    conditions[pk].map do |id|
      raise "id doesn't match primary key #{primary_key}" if id.size != primary_key.size
      new id: id
    end
  end

  def ==(other)
    id == other.try(:id)
  end
end
