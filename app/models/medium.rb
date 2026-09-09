class Medium < ApplicationRecord

  belongs_to :post

  validates :post_id, :medium_type, :presence => true

  attribute :medium_url
  attribute :medium_data

  after_initialize :generate_uuid
  before_destroy :remove_medium

  def medium_file
    File.join(Rails.root, 'public', 'image', 'media', "#{self.uuid}.webp")
  end

  def medium_url
    File.exist?(self.medium_file) ? "https://api.papacapim.just.pro.br/image/media/#{self.uuid}.webp" : nil
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid unless self.uuid.present?
  end

  def remove_medium
    File.delete(self.medium_file) if File.exist?(self.medium_file)
  end

end
