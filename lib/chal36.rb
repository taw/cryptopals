class Chal36
  class SRP
    def n
      DH.nist_prime
    end

    def g
      2
    end

    def k
      3
    end

    # The way we convert things for hashing is a bit BS
    # But it only matters that client and server do it the same way
    private def hash(msg)
      Digest::SHA256.hexdigest("#{msg}").to_i(16)
    end
  end

  class Server < SRP
    # Do not save password or x!
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
      @gb = (k*@v + g.powmod(@b, n)) % n
      @u = hash("#{@ga} #{@gb}")
      [@salt, @gb]
    end

    def round_3_recv(msg)
      s = (@ga * @v.powmod(@u, n)).powmod(@b, n)
      raise "Bad password" unless hash(s) == msg
      "OK"
    end
  end

  class Client < SRP
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
      @salt, @gb = msg
    end

    def round_3_send
      @u = hash("#{@ga} #{@gb}")
      x = hash(@salt + @password)
      s = (@gb - k*g.powmod(x, n)).powmod(@a + @u*x, n)
      hash(s)
    end
  end

  class Network
    def call(client, server)
      server.round_1_recv client.round_1_send
      client.round_2_recv server.round_2_send
      server.round_3_recv client.round_3_send
    end
  end
end
