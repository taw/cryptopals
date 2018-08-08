module AES
  class << self
    def random_key
      Random::DEFAULT.bytes(16)
    end

    def encrypt_block(block, key)
      raise unless block.size == 16 and key.size == 16
      encrypt(block, mode: "AES-128-ECB", key: key, padding: false)
    end

    def decrypt_block(block, key)
      raise unless block.size == 16 and key.size == 16
      decrypt(block, mode: "AES-128-ECB", key: key, padding: false)
    end

    def encrypt_ecb(msg, key)
      encrypt(msg, mode: "AES-128-ECB", key: key)
    end

    def encrypt_cbc(msg, key, iv)
      encrypt(msg, mode: "AES-128-CBC", key: key, iv: iv)
    end

    def encrypt_ctr(msg, key, iv)
      encrypt(msg, mode: "AES-128-CTR", key: key, iv: iv)
    end

    def decrypt_ecb(msg, key)
      decrypt(msg, mode: "AES-128-ECB", key: key)
    end

    def decrypt_cbc(msg, key, iv)
      decrypt(msg, mode: "AES-128-CBC", key: key, iv: iv)
    end

    def decrypt_ctr(msg, key, iv)
      decrypt(msg, mode: "AES-128-CTR", key: key, iv: iv)
    end

    private def encrypt(msg, mode:, key:, iv: nil, padding: true)
      crypt = OpenSSL::Cipher.new(mode)
      crypt.encrypt
      crypt.key = key
      crypt.iv = iv if iv
      crypt.padding = 0 unless padding
      crypt.update(msg) + crypt.final
    end

    private def decrypt(msg, mode:, key:, iv: nil, padding: true)
      crypt = OpenSSL::Cipher.new(mode)
      crypt.decrypt
      crypt.key = key
      crypt.iv = iv if iv
      crypt.padding = 0 unless padding
      crypt.update(msg) + crypt.final
    end
  end
end
