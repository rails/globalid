class Post < ActiveRecord::Base
  include GlobalID::Identification

  belongs_to :user

end