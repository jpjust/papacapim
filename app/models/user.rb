class User < ApplicationRecord

  has_secure_password

  has_many :sessions, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :likes, :dependent => :destroy

  validates :login, :name, :presence => true
  validates :login, :uniqueness => true

  after_save :check_password_change

  def check_password_change
    # Whenever the user changes the password we delete all sessions for security reasons
    Session.where(user_id: self.id).destroy_all if self.password_digest_changed?
  end

  def following
    Follower.where(follower_id: self.id).map(&:followed)
  end

  def followers
    Follower.where(followed_id: self.id).map(&:follower)
  end

end
