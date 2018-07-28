class Chal26
  class Box
    def initialize
      @key = AES.random_key
    end

    def prefix
      "comment1=cooking%20MCs;userdata="
    end

    def suffix
      ";comment2=%20like%20a%20pound%20of%20bacon"
    end

    def encrypt(msg)
      plaintext = prefix + msg.tr(";=", "") + suffix
      iv = AES.random_key
      iv + AES.encrypt_ctr(plaintext, @key, iv)
    end

    def decrypt(msg)
      iv = msg[0, 16]
      AES.decrypt_ctr(msg[16..-1], @key, iv)
    end
  end

  # Literally same attack works for CBC and CTR, but it actually hacks different block
  # CBC hacks second block, CTR first
  def hack(box)
    # For convenience, IV is 1 block and prefix is 2 blocks, so we don't need to realign things
    msg = "A" * 32
    hax = "AAAA;admin=true;"
    enc = box.encrypt(msg)
    enc[0,48] + enc[48,16].xor(hax).xor(msg[0,16]) + enc[64..-1]
  end
end
