class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :agents
  has_many :conversations
  has_one :company_profile
  has_many :tasks
  has_many :customers
  has_many :triggers
  has_many :api_keys

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
