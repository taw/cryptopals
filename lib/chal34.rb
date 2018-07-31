class Chal34
  class Client
    def initialize
      @msg = AES.random_key # Just somwe random bytes
      @p = DH.nist_prime
      @g = 2
      @a = rand(@p)
    end

    def round_1_send
      [@p, @g, ga]
    end

    def round_2_recv(msg)
      @gb = msg
      @key = DH.derive_key(@a, @gb, @p)
      nil
    end

    def round_3_send
      DH.encrypt(@msg, key)
    end

    def round_4_recv(msg)
      @received_msg = DH.decrypt(msg, key)
      nil
    end

    private

    def ga
      @g.powmod(@a, @p)
    end

    attr_reader :key, :msg, :received_msg
  end

  class Server
    def round_1_recv(msg)
      @p, @g, @ga = *msg
      nil
    end

    def round_2_send
      @b = rand(@p)
      @key = DH.derive_key(@b, @ga, @p)
      gb
    end

    def round_3_recv(msg)
      @received_msg = DH.decrypt(msg, @key)
      nil
    end

    def round_4_send
      DH.encrypt(@received_msg, @key)
    end

    private

    def gb
      @g.powmod(@b, @p)
    end

    attr_reader :key, :received_msg
  end

  class Network
    def call(client, server)
      server.round_1_recv client.round_1_send
      client.round_2_recv server.round_2_send
      server.round_3_recv client.round_3_send
      client.round_4_recv server.round_4_send
    end
  end

  class TraditionalMitmNetwork
    attr_reader :received_msg1, :received_msg2, :client_key, :server_key

    def call(client, server)
      # round 1
      @p, @g, @ga = client.round_1_send
      @fa = rand(@p)
      @gfa = @g.powmod(@fa, @p)
      server.round_1_recv [@p, @g, @gfa]

      # round 2
      @gb = server.round_2_send
      @fb = rand(@p)
      @gfb = @g.powmod(@fb, @p)
      client.round_2_recv @gfb
      @client_key = DH.derive_key(@fb, @ga, @p)
      @server_key = DH.derive_key(@fa, @gb, @p)

      # round 3
      @received_msg1 = DH.decrypt(client.round_3_send, @client_key)
      server.round_3_recv DH.encrypt(@received_msg1, @server_key)

      # round 4
      @received_msg2 = DH.decrypt(server.round_4_send, @server_key)
      client.round_4_recv DH.encrypt(@received_msg2, @client_key)
    end
  end

  class ParameterInjectionMitmNetwork
    attr_reader :received_msg1, :received_msg2, :key

    def call(client, server)
      @key = Digest::SHA1.digest(0.to_s(16).from_hex)[0,16]

      # round 1
      @p, @g, @ga = client.round_1_send
      server.round_1_recv [@p, @g, @p]

      # round 2
      @gb = server.round_2_send
      client.round_2_recv @p

      # round 3
      @received_msg1 = DH.decrypt(client.round_3_send, @key)
      server.round_3_recv DH.encrypt(@received_msg1, @key)

      # round 4
      @received_msg2 = DH.decrypt(server.round_4_send, @key)
      client.round_4_recv DH.encrypt(@received_msg2, @key)
    end
  end
end
