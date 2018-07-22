class Chal18
  def counter_block(nonce, block_num)
    [nonce, block_num].pack("Q<Q<")
  end

  def keystream(key, nonce, block_num)
    AES.encrypt_block(counter_block(nonce, block_num), key)
  end

  def decode(str, key, nonce)
    block_num = 0
    decoded = ""

    while block_num*16 < str.size
      plaintext_block = str[block_num*16, 16]
      keystream_block = keystream(key, nonce, block_num)[0, plaintext_block.size]
      decoded << plaintext_block.xor(keystream_block)
      block_num += 1
    end
    decoded
  end

  def encode(str, key, nonce)
    decode(str, key, nonce)
  end
end
