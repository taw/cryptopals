class Chal28
  def leftrotate(value, shift)
    return (((value << shift) | (value >> (32 - shift))) & 0xffffffff)
  end

  def pad_message(message)
    byte_string = message.bytes + [128]
    extra_zeroes = -(message.size + 9) % 64
    byte_string += [0] * extra_zeroes + [message.size*8].pack("Q>").bytes
    byte_string.each_slice(4).map{ |slice| slice.inject{ |a,b| (a<<8) + b } }
  end

  def sha1_reduce(chunk, hash_words)
    (16..79).each do |i|
      chunk << leftrotate((chunk[i-3] ^ chunk[i-8]  ^ chunk[i-14] ^ chunk[i-16]), 1)
    end
    working_vars = hash_words.dup

    80.times do |i|
      if (0 <= i && i <= 19)
        f = ((working_vars[1] & working_vars[2]) | (~working_vars[1] & working_vars[3]))
        k = 0x5A827999
      elsif (20 <= i && i <= 39)
        f = (working_vars[1] ^ working_vars[2] ^ working_vars[3])
        k = 0x6ED9EBA1
      elsif (40 <= i && i <= 59)
        f = ((working_vars[1] & working_vars[2]) | (working_vars[1] & working_vars[3]) | (working_vars[2] & working_vars[3]))
        k = 0x8F1BBCDC
      elsif (60 <= i && i <= 79)
        f = (working_vars[1] ^ working_vars[2] ^ working_vars[3])
        k = 0xCA62C1D6
      end
      # Complete round & Create array of working variables for next round.
      temp = (leftrotate(working_vars[0], 5) + f + working_vars[4] + k + chunk[i]) & 0xffffffff
      working_vars = [temp, working_vars[0], leftrotate(working_vars[1], 30), working_vars[2], working_vars[3]]
    end

    hash_words.zip(working_vars).map{ |a,b| (a+b) & 0xFFFF_FFFF }
  end

  def sha1(message)
    pad_string = pad_message(message)
    hash_words = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]

    pad_string.each_slice(16) do |chunk|
      hash_words = sha1_reduce(chunk, hash_words)
    end

    hash = ("%08x"*5) % hash_words
    hash
  end

  def mac(key, msg)
    sha1(key+msg)
  end
end
