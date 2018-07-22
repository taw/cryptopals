class Chal10
  def decode(encrypted, key, iv)
    raise unless encrypted.size % 16 == 0
    n = 0
    chain_val = iv
    result = ""

    while true
      slice = encrypted[n, 16]
      break if slice.empty?
      raise if slice.size != 16
      decoded = AES.decrypt_block(slice, key)
      result << decoded.xor(chain_val)
      chain_val = slice
      n += 16
    end

    strip_padding(result)
  end

  def strip_padding(str)
    pad_size = str[-1].ord
    padding = str[-pad_size..-1].unpack("C*")
    raise "Bad padding" unless padding == [pad_size] * pad_size
    str[0...-pad_size]
  end
end
