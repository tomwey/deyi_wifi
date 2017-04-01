class Client < ActiveRecord::Base
  validates :mac, presence: true
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.client_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:client_id => client_id)
    self.private_token = SecureRandom.uuid.gsub('-', '')
  end
  
end
