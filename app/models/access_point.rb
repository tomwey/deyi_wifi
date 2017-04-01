class AccessPoint < ActiveRecord::Base
  validates :ssid, :gw_mac, :gw_address, :gw_port, :merchant_id, presence: true
  belongs_to :merchant
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.ap_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:ap_id => ap_id)
  end
end
