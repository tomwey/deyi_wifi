class Connection < ActiveRecord::Base
  validates :access_point_id, :client_id, :expired_at, presence: true
  
  belongs_to :access_point
  belongs_to :client
  
  before_create :generate_unique_token
  def generate_unique_token
    begin
      self.token = SecureRandom.urlsafe_base64
    end while self.class.exists?(:token => token)
  end
  
  def closed?
    self.closed_at.present?
  end
  
  def expired?
    self.expired_at.blank? || self.expired_at < Time.zone.now
  end
  
  def close!
    self.closed_at = Time.zone.now
    self.save!
  end
  
end
