module AES
  class << self
    def random_key
      (0..15).map{ rand(256) }.pack("C*")
    end

    def encrypt_block(block, key)
      raise unless block.size == 16 and key.size == 16
      decipher = OpenSSL::Cipher.new("AES-128-ECB")
      decipher.encrypt
      decipher.padding = 0
      decipher.key = key
      decipher.update(block) + decipher.final
    end

    def decrypt_block(block, key)
      raise unless block.size == 16 and key.size == 16
      decipher = OpenSSL::Cipher.new("AES-128-ECB")
      decipher.decrypt
      decipher.padding = 0
      decipher.key = key
      decipher.update(block) + decipher.final
    end

    def encrypt_ecb(msg, key)
      crypt = OpenSSL::Cipher.new("AES-128-ECB")
      crypt.encrypt
      crypt.key = key
      crypt.update(msg) + crypt.final
    end

    def encrypt_cbc(msg, key, iv)
      crypt = OpenSSL::Cipher.new("AES-128-CBC")
      crypt.encrypt
      crypt.key = key
      crypt.iv = iv
      crypt.update(msg) + crypt.final
    end

    def decrypt_ecb(msg, key)
      crypt = OpenSSL::Cipher.new("AES-128-ECB")
      crypt.decrypt
      crypt.key = key
      crypt.update(msg) + crypt.final
    end
  end
end
