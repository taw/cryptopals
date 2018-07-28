class Chal30
  class Box
    def initialize(secret_size)
      @secret = secret_size.times.map{ rand(256) }.pack("C*")
    end

    # Secure method, hack doesn't get access to the box
    def sign(msg)
      OpenSSL::Digest::MD4.hexdigest(@secret + msg)
    end

    def valid?(msg, mac)
      sign(msg) == mac
    end
  end

  class MD4
    def pad_message(message)
      byte_string = message.unpack("C*") + [128]
      extra_zeroes = -(message.size + 9) % 64
      byte_string += [0] * extra_zeroes + [message.size*8].pack("Q<").unpack("C*")
      byte_string.each_slice(4).map{ |slice| slice.reverse.inject{ |a,b| (a<<8) + b } }
    end

    def rotate_left(v, s)
      mask = (1 << 32) - 1
      (v << s).&(mask) | (v.&(mask) >> (32 - s))
    end

    def md4_reduce(x, hash_words)
      mask = (1 << 32) - 1

      a, b, c, d = hash_words
      aa, bb, cc, dd = a, b, c, d

      rotations = [
        3,7,11,19, 3,7,11,19, 3,7,11,19, 3,7,11,19,
        3,5,9,13, 3,5,9,13, 3,5,9,13, 3,5,9,13,
        3,9,11,15, 3,9,11,15, 3,9,11,15, 3,9,11,15,
      ]
      schedule = [
        0,1,2,3, 4,5,6,7, 8,9,10,11, 12,13,14,15,
        0,4,8,12, 1,5,9,13, 2,6,10,14, 3,7,11,15,
        0,8,4,12, 2,10,6,14, 1,9,5,13, 3,11,7,15,
      ]

      48.times do |j|
        xi = x[schedule[j]]
        ri = rotations[j]
        if j <= 15
          u = b & c | (b ^ mask) & d
          k = 0
        elsif j <= 31
          u = b & c | b & d | c & d
          k = 0x5a827999
        else
          u = b ^ c ^ d
          k = 0x6ed9eba1
        end
        t = rotate_left(a + u + xi + k, ri)
        a, b, c, d = d, t, b, c
      end

      [
        (a + aa) & mask,
        (b + bb) & mask,
        (c + cc) & mask,
        (d + dd) & mask,
      ]
    end

    def md4(message)
      string = pad_message(message)

      hash_words = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476

      string.each_slice(16) do |x|
        hash_words = md4_reduce(x, hash_words)
      end

      hash_words.pack("V4").unpack("H*")[0]
    end
  end

  # If we don't get secret_size, we'll need to try all combinations
  def hack(secret_size, msg, mac, final)
    md4 = Chal30::MD4.new
    hash_words = [mac].pack("H*").unpack("V4")

    fake_secret = "A" * secret_size
    padded_orig_msg = md4.pad_message(fake_secret + msg)

    glue_padding = padded_orig_msg.pack("V*")[(fake_secret.size + msg.size)..-1]
    padded_hack_msg = md4.pad_message(fake_secret + msg + glue_padding + final)

    extra_data = padded_hack_msg[padded_orig_msg.size..-1]

    extra_data.each_slice(16) do |chunk|
      hash_words = md4.md4_reduce(chunk, hash_words)
    end

    hacked_mac = hash_words.pack("V4").unpack("H*")[0]

    [msg + glue_padding + final, hacked_mac]
  end
end
