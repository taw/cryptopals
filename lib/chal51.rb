class Chal51
  class Box
    def initialize(session_id)
      @key = AES.random_key
      @session_id = session_id
    end

    def create_request(content)
      [
        "POST / HTTP/1.1",
        "Host: hapless.com",
        "Cookie: sessionid=#{@session_id}",
        "Content-Length: #{content.size}",
        "",
        content,
      ].join("\r\n")
    end

    def compress(data)
      Zlib::Deflate.deflate(data)
    end

    def uncompress(data)
      Zlib::Inflate.inflate(data)
    end

    def encode(content)
      encrypt(compress(create_request(content)))
    end

    def decode(content)
      uncompress(decrypt(content))
    end
  end

  class BoxCTR < Box
    def encrypt(data)
      iv = AES.random_key
      iv + AES.encrypt_ctr(data, @key, iv)
    end

    def decrypt(data)
      iv, data = data[0..15], data[16..-1]
      AES.decrypt_ctr(data, @key, iv)
    end
  end

  class BoxCBC < Box
    def encrypt(data)
      iv = AES.random_key
      iv + AES.encrypt_cbc(data, @key, iv)
    end

    def decrypt(data)
      iv, data = data[0..15], data[16..-1]
      AES.decrypt_cbc(data, @key, iv)
    end
  end

  def base_prefix
    "Cookie: sessionid="
  end

  def base_alphabet
    [*"A".."Z", *"a".."z", *"0".."9", "+", "/", "=", "\r"]
  end

  def find_alignment_block(box, prefix)
    block = 64.times.map{ rand(200..254) }.pack("C*") + "\x03" * 16
    while true
      next_char = [rand(200..254)].pack("C*")
      this_candidate = block + "\x02"
      next_candidate = block + next_char
      this_size = box.encode(this_candidate + prefix + "\x01").size
      next_size = box.encode(next_candidate + prefix + "\x01").size
      if this_size < next_size
        return this_candidate
      end
      block += next_char
    end
  end

  # This is a multistep process, with retries:
  #
  # * First, get approximate alignment for big block (like CBC)
  # * Then, get microalignment block, should take few bits
  # * Each time try every character, which compresses best
  # * Just in case try twice on each character
  #
  # If we could reliably produce bits, we wouldn't need it
  # The more we know about compression algorithm, the better our attack would be
  # But even with very rudimentary knowledge it's fine
  #
  # Use of all weird values (01, 02, 04, 200..254 etc.) is in hope it would reduce
  # false positive with some compressible data, but it's unclear if it helps at all

  def extend_one_character(box, prefix)
    32.times do |i|
      alignment_block = find_alignment_block(box, prefix)[0..-3]

      32.times do
        alignment_block += "\x04"
        result = base_alphabet.map{|c| [ c, box.encode(alignment_block + prefix + c).size ] }.to_h
        min = result.values.min
        candidates = result.select{|c,v| v == min}

        if candidates.size == 1
          return candidates.keys[0]
        end
      end

      # warn "#{box.class} alignment failed #{i} - retrying"
    end
    raise "Definitely broken"
  end

  def hack(box)
    session_key = ""
    while true
      while true
        next_character   = extend_one_character(box, base_prefix + session_key)
        next_character_2 = extend_one_character(box, base_prefix + session_key)
        break if next_character == next_character_2
      end
      if next_character == "\r"
        return session_key
      else
        session_key += next_character
      end
    end
  end
end
