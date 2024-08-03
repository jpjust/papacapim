class Post < ApplicationRecord

  belongs_to :user

  has_many :replies, class_name: 'Post', foreign_key: 'post_id', :dependent => :destroy
  has_many :likes, :dependent => :destroy

  validates :user_id, :message, :presence => true

  default_scope { order(created_at: :desc) }

  attribute :user_login

  def user_login
    user.try(:login)
  end

end
