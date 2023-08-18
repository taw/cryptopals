class Chal14
  # Same as Chal12
  private def unknown_string
    "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
    aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
    dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
    YnkK"
  end

  def box
    key = AES.random_key
    proc do |txt|
      # If prefix is different every time, and different length, then it's harder
      random_prefix = Random.bytes(rand(10..100))
      AES.encrypt_ecb(random_prefix + txt + Base64.decode64(unknown_string), key)
    end
  end

  def alignment_block
    "A"*32 + "B"*16 + "A"*32
  end

  # This tries an average of 16 times to get aligned encryption
  def encrypt(box, message)
    while true
      # We add even more randomness to erase any patterns in random_prefix
      # It's not necessary for this one, but could be in more realistic attack
      random_pad = "A" * rand(0..15)
      encrypted = box.call(random_pad + alignment_block + message)
      i = 0
      while i + 80 < encrypted.size
        blocks = encrypted[i, 80]
        if blocks[0,16] == blocks[16,16] &&
           blocks[0,16] != blocks[32,16] &&
           blocks[0,16] == blocks[48,16] &&
           blocks[0,16] == blocks[64,16]
          return encrypted[i+80..-1]
        end
        i += 16
      end
    end
  end

  def message_size(box)
    i = 0
    sz = encrypt(box, "").size
    while true
      sz2 = encrypt(box, "A" * i).size
      if sz2 != sz
        # There's always minimum padding of 1
        return sz - i
      end
      i += 1
    end
  end

  def crack_message(box)
    block_size = 16
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
    target = encrypt(box, prefix)[block_index * block_size, block_size]
    (0..255).each do |i|
      block = encrypt(box, prefix + known + [i].pack("C"))[block_index * block_size, block_size]
      return i.chr if block == target
    end
    raise "FAILED!"
  end
end
