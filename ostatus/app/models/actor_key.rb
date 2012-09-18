require 'openssl'

# Store OStatus private and public key
class ActorKey < ActiveRecord::Base
  KEY_SIZE = 1024

  belongs_to :actor

  validates_presence_of :key_der

  before_validation :generate_key, on: :create

  def key
    @key ||=
      OpenSSL::PKey::RSA.new(key_der)
  end

  def key= new_key
    @key = new_key
    self.key_der = new_key.to_der
  end

  private

  def generate_key
    return if key_der.present?

    self.key = OpenSSL::PKey::RSA.generate(KEY_SIZE)
  end
end
