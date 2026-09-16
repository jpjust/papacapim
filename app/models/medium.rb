class Medium < ApplicationRecord

  belongs_to :post

  validates :post_id, :medium_type, :presence => true

  attribute :medium_url
  attribute :medium_data

  after_initialize :generate_uuid
  before_destroy :remove_medium

  def medium_file
    File.join(Rails.root, 'public', 'image', 'media', "#{self.uuid}.#{self.extension}")
  end

  def medium_url
    if Rails.env.development?
      File.exist?(self.medium_file) ? "http://localhost:3002/image/media/#{self.uuid}.#{self.extension}" : nil
    else
      File.exist?(self.medium_file) ? "https://api.papacapim.just.pro.br/image/media/#{self.uuid}.#{self.extension}" : nil
    end
  end

  private

  def extension
    case self.medium_type
    when 'image'
      return 'webp'
    when 'video'
      return 'mp4'
    end

    ''
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid unless self.uuid.present?
  end

  def remove_medium
    File.delete(self.medium_file) if File.exist?(self.medium_file)
  end

end
