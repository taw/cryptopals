class Chal13
  class << self
    def parse_query(query)
      query.split("&").map{|q|
        q.split("=", 2)
      }.to_h
    end

    def build_query_string(hash)
      hash.map{|k,v|
        k.to_s.tr("&=", "") + "=" + v.to_s.tr("&=", "")
      }.join("&")
    end

    def profile_for(email)
      build_query_string({
        "email" => email,
        "uid" => 10,
        "role" => "user",
      })
    end
  end

  class Box
    def initialize
      @key = AES.random_key
    end

    def encrypt(email)
      AES.encrypt_ecb(Chal13.profile_for(email), @key)
    end

    def decrypt(encrypted)
      Chal13.parse_query(AES.decrypt_ecb(encrypted, @key))
    end
  end

  def hack(box)
    block0 = box.encrypt("A"*10)[0,16]
    block1 = box.encrypt("A"*13)[16,16]
    block2 = box.encrypt("A"*10 + "admin")[16,16]
    block3 = box.encrypt("A"*0)[16,16]

    (block0+block1+block2+block3)
  end
end
