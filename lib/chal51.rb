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

end
