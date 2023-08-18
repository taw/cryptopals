class Chal25
  class Box
    attr_reader :size, :disk

    def initialize(size)
      @nonce = rand(2**64)
      @key = AES.random_key
      @size = size
      @disk = Random.bytes(@size)
    end

    def write(ofs, data)
      before_bytes = ofs % 16
      if before_bytes
        data = read(ofs, before_bytes) + data
        ofs -= before_bytes
      end
      if data.size % 16 != 0
        after_bytes = 16 - (data.size % 16)
        data += read(ofs + data.size, after_bytes)
      end

      block_num = ofs/16
      (data.size/16).times do |i|
        write_block(block_num + i, data[16*i, 16])
      end
    end

    private def read(ofs, count)
      result = ""
      while result.size < count
        block_num, block_ofs = ofs.divmod(16)
        block_count = [count, 16  - block_ofs].max
        block = read_block(block_num)
        result += block[block_ofs, block_count]
        ofs += block_count
        count -= block_count
      end
      result
    end

    # Not security relevant, just implementation detail
    private def write_block(block_num, data)
      raise unless data.size == 16
      @disk[16 * block_num, 16] = data.xor(keystream(block_num))
    end

    private def read_block(block_num)
      @disk[16 * block_num, 16].xor(keystream(block_num))
    end

    private def counter_block(block_num)
      [@nonce, block_num].pack("Q<Q<")
    end

    private def keystream(block_num)
      AES.encrypt_block(counter_block(block_num), @key)
    end
  end

  def hack(box)
    result = ""
    zero = ([0] * 16).pack("C*")
    (box.size/16).times do |i|
      orig = box.disk[i*16, 16]
      box.write(i*16, zero)
      decrypted = box.disk[i*16, 16].xor(orig)
      box.write(i*16, decrypted)
      result << decrypted
    end
    result
  end
end
