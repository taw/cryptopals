class Chal20
  def decrypt(encrypted)
    max_size = encrypted.map(&:size).max
    keystream = []

    (0...max_size).each do |i|
      slice = encrypted.map{|e| e[i]}.compact.map(&:ord)
      key, decrypted_slice = guess_key(slice)
      keystream << key
    end

    decrypted = encrypted.map{|slice|
      slice.unpack("C*").map.with_index{|c,i| c ^ keystream[i]}.pack("C*")
    }

    decrypted
  end

 def guess_key(input)
    (0..255).map{|key|
      decoded = input.map{|u| u^key}.pack("C*")
      [English.score(decoded), key, decoded]
    }.sort[0][1,2]
  end
end
