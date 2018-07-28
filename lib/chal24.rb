class Chal24
  class Cipher
    def initialize(key)
      @key = key
    end

    def encrypt(msg)
      msg.xor(keystream(msg.size))
    end

    def decrypt(msg)
      msg.xor(keystream(msg.size))
    end

    def keystream(size)
      rng = Chal21.new
      rng.seed(@key)
      result = ""
      while result.size < size
        result << [rng.extract_number].pack("V")
      end
      result[0, size]
    end
  end

  def hack(ciphertext)
    plaintext = "A" * 14

    possible_keys = (Time.now.to_i-2**15-100..Time.now.to_i+2**15+100)
    possible_keys.each do |key|
      cipher = Chal24::Cipher.new(key)
      if cipher.decrypt(ciphertext)[-14..-1] == plaintext
        return key
      end
    end

    raise "Attack failed"
  end
end
