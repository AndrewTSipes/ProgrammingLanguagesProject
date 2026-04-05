# encryption_service.rb

require "openssl"
require "base64"
require "digest"

class EncryptionService
  ALGORITHM = "AES-256-CBC"

  def initialize(master_password)
    # Uses SHA256 to build a key
    @key = Digest::SHA256.digest(master_password)
  end

  # Encrypts plain text and returns Base64 encoded string
  def encrypt(plaintext)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.encrypt
    cipher.key = @key
    iv = cipher.random_iv

    encrypted = cipher.update(plaintext) + cipher.final

    # Store IV + encrypted info together, Base64 encoded
    Base64.strict_encode64(iv + encrypted)
  end

  # Decrypts Base64 encoded ciphertext
  def decrypt(encoded_ciphertext)
    raw = Base64.strict_decode64(encoded_ciphertext)

    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.decrypt
    cipher.key = @key

    # Extract IV 
    iv = raw[0..15]
    encrypted = raw[16..]

    cipher.iv = iv

    cipher.update(encrypted) + cipher.final
  rescue
    # If decryption fails 
    nil
  end
end