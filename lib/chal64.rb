class Chal64
  class << self
    def gcm_mul_matrix(c)
      c = GCMField.new(c)
      GF2Matrix.build(128) do |i|
        (c * GCMField.new(i)).value
      end
    end

    def gcm_square_matrix
      GF2Matrix.build(128) do |i|
        i = GCMField.new(i)
        (i * i).value
      end
    end

    def string_to_number(s)
      # Is this the right endian?
      s.to_hex.to_i(16)
    end

    # sum(Mdi * Ms^i)
    def diff_matrix(diffs)
      ms = gcm_square_matrix
      mds = diffs.map do |diff|
        c = string_to_number(diff)
        gcm_mul_matrix(c)
      end
      result = GF2Matrix.zero(128)
      mds.each_with_index do |md, i|
        result += md * (ms ** (i+1))
      end
      result
    end

    def apply_diff(str, diffs)
      str = str.dup
      diffs.each_with_index do |diff, i|
        block_number = 2**(i+1)
        ofs = str.size - (block_number-2)*16 - 16
        raise "Trying to diff past end of messace" if ofs < 0
        str[ofs, 16] = str[ofs, 16].xor(diff)
      end
      str
    end
  end
end
