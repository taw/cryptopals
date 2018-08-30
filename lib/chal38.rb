class Chal38
  class BadSRP
    def n
      DH.nist_prime
    end

    def g
      2
    end

    private def hash(msg)
      Digest::SHA256.hexdigest("#{msg}").to_i(16)
    end

    def hmac(key, msg)
      digest = OpenSSL::Digest::SHA256.new
      hmac = OpenSSL::HMAC.new("#{key}", digest)
      hmac << "#{msg}"
      hmac.digest
    end
  end

  class Server < BadSRP
    def initialize(email, password)
      @email = email
      @salt = Random::DEFAULT.bytes(16)
      x = hash(@salt + password)
      @v = g.powmod(x, n)
    end

    def round_1_recv(msg)
      raise "Bad email" unless msg[0] == @email
      @ga = msg[1]
    end

    def round_2_send
      @b = rand(2...n)
      @gb = g.powmod(@b, n)
      @u = rand(2**128)
      [@salt, @gb, @u]
    end

    def round_3_recv(msg)
      s = (@ga * @v.powmod(@u, n)).powmod(@b, n)
      k = hash(s)
      raise "Bad password" unless msg == hmac(k, @salt)
      "OK"
    end
  end

  class Client < BadSRP
    def initialize(email, password)
      @email = email
      @password = password
    end

    def round_1_send
      @a = rand(2...n)
      @ga = g.powmod(@a, n)
      [@email, @ga]
    end

    def round_2_recv(msg)
      @salt, @gb, @u = msg
    end

    def round_3_send
      x = hash(@salt + @password)
      s = @gb.powmod(@a + @u*x, n)
      k = hash(s)
      hmac(k, @salt)
    end
  end

  class Network
    def call(client, server)
      server.round_1_recv client.round_1_send
      client.round_2_recv server.round_2_send
      server.round_3_recv client.round_3_send
    end
  end

  class FakeServer < BadSRP
    def round_1_recv(msg)
      @email, @ga = msg
      @salt = Random::DEFAULT.bytes(16)
    end

    def round_2_send
      @b = rand(2...n)
      @gb = g.powmod(@b, n)
      @u = rand(2**128)
      [@salt, @gb, @u]
    end

    def round_3_recv(msg)
      gab = @ga.powmod(@b, n)
      words.each do |candidate_password|
        x = hash(@salt + candidate_password.b) # can be precomputed
        vub = g.powmod(x*@u*@b, n) # can be precomputed
        s = (gab * vub) % n
        k = hash(s)
        if msg == hmac(k, @salt)
          @password = candidate_password
          return "OK"
        end
      end
      raise "Bad password"
    end

    def dict_path
      "/usr/share/dict/words"
    end

    def words
      Pathname(dict_path).readlines.map(&:chomp).map(&:downcase).sort.uniq
    end
  end
end
