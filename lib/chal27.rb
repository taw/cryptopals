class Chal27
  class Box
    def initialize(key)
      @key = key
    end

    def encrypt(msg)
      AES.encrypt_cbc(msg, @key, @key)
    end

    private def decrypt(msg)
      AES.decrypt_cbc(msg, @key, @key)
    end

    def access(msg)
      plaintext = AES.decrypt_cbc(msg, @key, @key)
      if plaintext.unpack("C*").any?{|c| c >= 128}
        [:bad_msg, plaintext]
      else
        [:ok]
      end
    end
  end

  # Attack message is:
  # * 1 IV block
  # * 2 attack blocks
  # * 2 good blocks so we don't need to mess with padding
  def hack(box)
    encrypted = box.encrypt("A" * 64)
    attack_msg = encrypted[0,16] + ([0]*16).pack("C*") + encrypted[0,16] + encrypted[48,32]
    response = box.access(attack_msg)
    raise "Attack failed" if response[0] == :ok
    attack_decrypted = response[1]
    attack_decrypted[0,16].xor(attack_decrypted[32,16])
  end
end
