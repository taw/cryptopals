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
      crypt.key = key
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

  def guess_first_char(box)
    block_size = detect_block_size(box)
    raise unless ecb?(box)
    guess_next_byte(box, block_size, "")
  end

  def guess_first_block(box)
    block_size = detect_block_size(box)
    raise unless ecb?(box)

    known = ""
    block_size.times do |k|
      known << guess_next_byte(box, block_size, known)
    end
    known
  end

  private def guess_next_byte(box, block_size, known)
    prefix = "A" * (block_size - known.size - 1)
    target = box.call(prefix)[0, block_size]
    (0..255).each do |i|
      block = box.call(prefix + known + [i].pack("C"))[0, block_size]
      return i.chr if block == target
    end
    binding.pry
    raise "FAILED!"
  end
end
