class Like < ApplicationRecord

  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }

  attribute :user_login

  def user_login
    user.try(:login)
  end

end
