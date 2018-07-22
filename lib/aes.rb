module AES
  def self.encrypt_block(block, key)
    raise unless block.size == 16 and key.size == 16
    decipher = OpenSSL::Cipher.new("AES-128-ECB")
    decipher.encrypt
    decipher.padding = 0
    decipher.key = key
    decipher.update(block) + decipher.final
  end

  def self.decrypt_block(block, key)
    raise unless block.size == 16 and key.size == 16
    decipher = OpenSSL::Cipher.new("AES-128-ECB")
    decipher.decrypt
    decipher.padding = 0
    decipher.key = key
    decipher.update(block) + decipher.final
  end
end
