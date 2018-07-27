class Chal17
  class Box
    private def strings
      %W[
        MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=
        MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=
        MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==
        MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==
        MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl
        MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==
        MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==
        MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=
        MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=
        MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93
      ]
    end

    def initialize
      @key = AES.random_key
      @random_string = Base64.decode64(strings.sample)
    end

    def encrypt_random_string
      iv = AES.random_key
      iv + AES.encrypt_cbc(@random_string, @key, iv)
    end

    def valid?(msg)
      iv = msg[0, 16]
      AES.decrypt_cbc(msg[16..-1], @key, iv)
      true
    rescue OpenSSL::Cipher::CipherError
      false
    end

    def hacked?(guess)
      guess == @random_string
    end
  end

  # If ending is 02 01
  # Then 01 and 02 would both be valid guesses
  # Problem doesn't apply beyond that, as we know last byte
  def hack_byte(box, b1, b0, found)
    padding_target = 1 + found.size
      postmask = found.map{|f| f ^ padding_target}.pack("C*")

    if found.empty?
      premask = ([0] * (16 - found.size - 2)).pack("C*")

      (0..255).each do |i|
        maska = premask + [0, i ^ padding_target].pack("CC") + postmask
        maskb = premask + [128, i ^ padding_target].pack("CC") + postmask
        if box.valid?(b1.xor(maska) + b0) and box.valid?(b1.xor(maskb) + b0)
          return i
        end
      end
    else
      premask = ([0] * (16 - found.size - 1)).pack("C*")

      (0..255).each do |i|
        maska = premask + [i ^ padding_target].pack("C") + postmask
        if box.valid?(b1.xor(maska) + b0)
          return i
        end
      end
    end

    raise "Attack failed"
  end

  def hack_block(box, b1, b0)
    found = []
    16.times do
      found.unshift hack_byte(box, b1, b0, found)
    end

    found.pack("C*")
  end

  def hack(box)
    msg = box.encrypt_random_string
    decrypted = ""
    while msg.size >= 32
      b1 = msg[-32,16]
      b0 = msg[-16,16]
      decrypted = hack_block(box, b1, b0) + decrypted
      msg = msg[0...-16]
    end
    # First block is IV so we don't need to decode it

    strip_padding(decrypted)
  end

  def strip_padding(str)
    pad_size = str[-1].ord
    padding = str[-pad_size..-1].unpack("C*")
    raise "Bad padding" unless padding == [pad_size] * pad_size
    str[0...-pad_size]
  end
end
