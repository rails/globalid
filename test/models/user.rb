class User < ActiveRecord::Base
  include GlobalID::Identification

  has_many :posts

end