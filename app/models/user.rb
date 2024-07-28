class User < ApplicationRecord

  has_secure_password

  has_many :sessions, :dependent => :destroy
  has_many :posts, :dependent => :destroy

  validates :login, :name, :presence => true
  validates :login, :uniqueness => true

end
