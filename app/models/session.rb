class Session < ApplicationRecord

  belongs_to :user

  validates :user_id, :token, :ip, :presence => true
  validates :token, :uniqueness => true

  before_validation :generate_token

  def generate_token
    self.token = SecureRandom.uuid if token.blank?
  end

end
