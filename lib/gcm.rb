module GCM
  class << self
    # no reflection version
    # Such a weird hack
    def mul(a, b)
      result = 0
      mask = 2**128 + 2**127 + 2**126 + 2**121 + 1
      max = 2**128
      while a > 0 and b > 0
        if b[127] == 1
          result ^= a
        end
        b = (b << 1) & (max - 1)

        if a.odd?
          a ^= mask
        end
        a >>= 1
      end
      result
    end

    # this is stupid version
    def mul_reflect(a, b)
      a = reflect128(a)
      b = reflect128(b)
      result = 0

      mask = 2**128 + 128 + 4 + 2 + 1
      max = 2**128
      while a > 0 and b > 0
        if b.odd?
          result ^= a
        end
        b >>= 1

        a <<= 1
        if a >= max
          a ^= mask
        end
      end

      reflect128(result)
    end

    private def reflect128(n)
      ("%0128b" % n).reverse.to_i(2)
    end

    def encrypt(key, iv, aad, pt)
      aad = aad.b
      pt = pt.b
      h = calculate_h(key)
      tag = 0
      ct = "".b

      # Associated Data
      each_aad_block(aad) do |block|
        tag = mul(h, tag ^ block.to_hex.to_i(16))
      end

      # Plaintext
      each_message_block_ctr(pt, key, iv) do |block, ctr_block|
        ct_block = block.xor(ctr_block)
        ct << ct_block
        ctval = ct_block + "\x00".b * (16 - block.size)
        tag = mul(h, tag ^ ctval.to_hex.to_i(16))
      end

      final_block = (aad.bytesize*8) * (2**64) | pt.bytesize*8
      tag = mul(h, tag^final_block)
      tag ^= iv_block(key, iv)

      [aad, ct, tag]
    end

    def decrypt(key, iv, aad, ct)
      aad = aad.b
      ct = ct.b
      h = calculate_h(key)
      tag = 0
      pt = "".b

      # Associated Data
      each_aad_block(aad) do |block|
        tag = mul(h, tag ^ block.to_hex.to_i(16))
      end

      # Plaintext
      each_message_block_ctr(ct, key, iv) do |block, ctr_block|
        pt_block = block.xor(ctr_block)
        pt << pt_block
        ctval = block + "\x00".b * (16 - block.size)
        tag = mul(h, tag ^ ctval.to_hex.to_i(16))
      end

      tag = mul(h, tag^final_block(aad, ct))
      tag ^= iv_block(key, iv)

      [aad, pt, tag]
    end

    def final_block(aad, ct)
      (aad.bytesize*8) * (2**64) | ct.bytesize*8
    end

    def calculate_h(key)
      zero_block = "\x00".b*16
      encrypt_block(key, zero_block).to_hex.to_i(16)
    end

    def iv_block(key, iv)
      encrypt_block(key, counter_block(iv, 1)).to_hex.to_i(16)
    end

    def each_aad_block(aad)
      i = 0
      while i*16 < aad.size
        block = aad[i*16, 16]
        block += "\x00".b * (16 - block.size)
        yield(block)
        i += 1
      end
    end

    def each_message_block(message)
      j = 0
      while j*16 < message.size
        block = message[j*16, 16]
        yield(block, j)
        j += 1
      end
    end

    # PT / CT - yield blocks and corresponding counter blocks
    def each_message_block_ctr(message, key, iv)
      each_message_block(message) do |block, j|
        ctr_block = encrypt_block(key, counter_block(iv, j+2))
        yield(block, ctr_block[0, block.size])
      end
    end

    def counter_block(iv, i)
      iv + [i].pack("N")
    end

    def encrypt_block(key, block)
      raise unless block.size == 16 and key.size == 16
      crypt = OpenSSL::Cipher.new("AES-128-ECB")
      crypt.encrypt
      crypt.key = key
      crypt.padding = 0
      crypt.update(block) + crypt.final
    end
  end
end
