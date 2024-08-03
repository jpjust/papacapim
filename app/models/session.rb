class Session < ApplicationRecord

  belongs_to :user

  validates :user_id, :token, :ip, :presence => true
  validates :token, :uniqueness => true

  before_validation :generate_token

  attribute :user_login

  def generate_token
    self.token = SecureRandom.uuid if token.blank?
  end

  def user_login
    user.try(:login)
  end

end
