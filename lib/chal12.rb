class Chal12
  private def unknown_string
    "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
    aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
    dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
    YnkK"
  end

  def random_key
    (0..15).map{ rand(256) }.pack("C*")
  end

  def box
    key = random_key
    proc do |txt|
      crypt = OpenSSL::Cipher.new("AES-128-ECB")
      crypt.encrypt
      crypt.key = random_key
      crypt.update(txt + Base64.decode64(unknown_string)) + crypt.final
    end
  end

  def detect_block_size(box)
    i = 1
    sz = box.("A" * i).size
    while true
      sz2 = box.("A" * i).size
      if sz == sz2
        i += 1
      else
        return sz2 - sz
      end
    end
  end

  def ecb?(box)
    encrypted = box.call("A" * 100)
    slices = encrypted.chars.each_slice(16).map(&:join)
    slices.size != slices.uniq.size
  end
end
