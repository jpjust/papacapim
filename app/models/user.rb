class User < ApplicationRecord

  has_secure_password

  has_many :sessions, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :followers, :class_name => Follower.to_s, :foreign_key => :followed_id, :dependent => :destroy
  has_many :following, :class_name => Follower.to_s, :foreign_key => :follower_id, :dependent => :destroy

  validates :login, :name, :presence => true
  validates :login, :uniqueness => true

  default_scope { order(created_at: :desc) }

end
