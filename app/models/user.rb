class User < ApplicationRecord

  has_secure_password

  has_many :sessions, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :followers, :class_name => Follower.to_s, :foreign_key => :followed_id, :dependent => :destroy
  has_many :following, :class_name => Follower.to_s, :foreign_key => :follower_id, :dependent => :destroy

  validates :login, :name, :presence => true
  validates :login, :uniqueness => true
  validates :login, length: { minimum: 3 }

  default_scope { order(created_at: :desc) }

  attribute :profile_image
  attribute :image_data
  attribute :followers_number
  attribute :following_number
  attribute :you_follow
  attribute :follows_you

  before_save :generate_uuid
  before_destroy :remove_image

  def img_file
    File.join(Rails.root, 'public', 'image', 'profile', "#{self.uuid}.webp")
  end

  def profile_image
    File.exist?(self.img_file) ? "https://api.papacapim.just.pro.br/image/profile/#{self.uuid}.webp" : nil
  end

  def followers_number
    self.followers.count
  end

  def following_number
    self.following.count
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid unless self.uuid.present?
  end

  def remove_image
    File.delete(self.img_file)
  end

end
