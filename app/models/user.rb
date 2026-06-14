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

  attribute :profile_image
  attribute :image_data

  def img_file
    File.join(Rails.root, 'public', 'image', 'profile', "#{self.login.strip}.webp")
  end

  def profile_image
    File.exist?(self.img_file) ? "https://api.papacapim.just.pro.br/image/profile/#{self.login.strip}.webp" : nil
  end

end
