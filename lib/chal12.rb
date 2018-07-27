class Chal12
  private def unknown_string
    "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
    aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
    dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
    YnkK"
  end

  def box
    key = AES.random_key
    proc do |txt|
      AES.encrypt_ecb(txt + Base64.decode64(unknown_string), key)
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

  def crack_first_char(box)
    block_size = detect_block_size(box)
    raise unless ecb?(box)
    crack_next_byte(box, block_size, "")
  end

  def crack_first_block(box)
    block_size = detect_block_size(box)
    raise unless ecb?(box)

    known = ""
    block_size.times do |k|
      known << crack_next_byte(box, block_size, known)
    end
    known
  end

  def message_size(box)
    i = 0
    sz = box.call("").size
    while true
      sz2 = box.call("A" * i).size
      if sz2 != sz
        # There's always minimum padding of 1
        return sz - i
      end
      i += 1
    end
  end

  def crack_message(box)
    block_size = detect_block_size(box)
    raise unless ecb?(box)
    message_size = message_size(box)

    known = ""
    message_size.times do |k|
      known << crack_next_byte(box, block_size, known)
    end
    # strip padding
    known
  end

  private def crack_next_byte(box, block_size, known)
    prefix_size = block_size - known.size - 1
    block_index = 0
    while prefix_size < 0
      prefix_size += block_size
      block_index += 1
    end
    prefix = "A" * prefix_size
    target = box.call(prefix)[block_index * block_size, block_size]
    (0..255).each do |i|
      block = box.call(prefix + known + [i].pack("C"))[block_index * block_size, block_size]
      return i.chr if block == target
    end
    raise "FAILED!"
  end
end
