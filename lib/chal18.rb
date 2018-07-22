class Chal18
  def counter_block(nonce, block_num)
    [nonce, block_num].pack("Q<Q<")
  end

  def keystream(key, nonce, block_num)
    AES.encrypt_block(counter_block(nonce, block_num), key)
  end

  def xor(s1, s2)
    raise unless s1.size == s2.size
    (0...s1.size).map{|i| (s1[i] ^ s2[i]).chr }.join
  end

  def decode(str, key, nonce)
    block_num = 0
    decoded = ""

    str = str.unpack("C*")
    while block_num*16 < str.size
      plaintext_block = str[block_num*16, 16]
      keystream_block = keystream(key, nonce, block_num)[0, plaintext_block.size].unpack("C*")
      decoded << xor(plaintext_block, keystream_block)
      block_num += 1
    end
    decoded
  end
end
