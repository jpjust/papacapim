class User < ApplicationRecord

  has_secure_password

  has_many :sessions, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :likes, :dependent => :destroy

  validates :login, :name, :presence => true
  validates :login, :uniqueness => true

  default_scope { order(created_at: :desc) }

  def following
    Follower.where(follower_id: self.id).map(&:followed)
  end

  def followers
    Follower.where(followed_id: self.id).map(&:follower)
  end

end
