class Session < ApplicationRecord
  belongs_to :user

  before_create :generate_token

  private

  def generate_token
    self.token = Digest::SHA1.hexdigest("#{user.id}-#{Time.current.to_i}-#{SecureRandom.hex(4)}")
  end
end
