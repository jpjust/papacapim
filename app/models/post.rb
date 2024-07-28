class Post < ApplicationRecord

  belongs_to :user

  has_many :replies, class_name: 'Post', foreign_key: 'post_id', :dependent => :destroy
  has_many :likes, :dependent => :destroy

  validates :user_id, :message, :presence => true

end
