class Follower < ApplicationRecord

  belongs_to :follower, :class_name => 'User', :foreign_key => 'follower_id'
  belongs_to :followed, :class_name => 'User', :foreign_key => 'followed_id'

  validates :followed_id, uniqueness: { scope: :follower_id }

  before_save :check_self_following

  def check_self_following
    throw :abort if self.follower_id == self.followed_id
  end

end
