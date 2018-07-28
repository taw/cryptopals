class Chal19
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

  def transform_for_most_spaces!(data)
    max_size = data.map(&:size).max
    max_size.times do |i|
      counts = Hash.new(0)
      slice = data.map{|e| e[i]}.compact
      slice.each do |s|
        counts[s] += 1
      end
      best_guess = counts.sort_by(&:last).last.first.ord ^ 32
      data.each do |msg|
        if msg[i]
          msg[i] = (msg[i].ord ^ best_guess).chr
        end
      end
    end
    data
  end

  def tranform_manual!(data, msg_index, char_index, char)
    key = data[msg_index][char_index].ord ^ char.ord
    data.each do |msg|
      if msg[char_index]
        msg[char_index] = (msg[char_index].ord ^ key).chr
      end
    end
    data
  end
end
