class User < ApplicationRecord

  has_secure_password

  validates_presence_of :login, :name

  validates_uniqueness_of :login

end
