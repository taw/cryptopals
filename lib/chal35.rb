class Chal35
  # Challenge 35 splits first message between p/g and A
  # unlike previous challenge 34 which kept them together,
  # but it really doesn't matter for anything so keeping it
  # in challenge 34's version

  Client = Chal34::Client
  Server = Chal34::Server
  Network = Chal34::Network


  # Just injecting g will not affect server key at all
  # unless we also change A to match the new g
  #
  # It will affect client key very much

  class GInjectionNetwork1
    attr_reader :received_msg1, :received_msg2, :key

    def call(client, server)
      # round 1
      @p, @g, @ga = client.round_1_send
      server.round_1_recv [@p, 1, 1]

      # round 2
      @gb = server.round_2_send
      client.round_2_recv @gb

      # This makes gB == 1
      # and so alice s == 1
      # however server key is not affected by this attack

      # @key = Digest::SHA1.digest(0.to_s(16).from_hex)[0,16]
      @key = DH.derive_key(1, 1, @p)

      # # round 3
      @received_msg1 = DH.decrypt(client.round_3_send, @key)
      server.round_3_recv DH.encrypt(@received_msg1, @key)

      # # round 4
      @received_msg2 = DH.decrypt(server.round_4_send, @key)
      client.round_4_recv DH.encrypt(@received_msg2, @key)
    end
  end

  class GInjectionNetworkP
    attr_reader :received_msg1, :received_msg2, :key

    def call(client, server)
      # round 1
      @p, @g, @ga = client.round_1_send
      server.round_1_recv [@p, @p, 0]

      # round 2
      @gb = server.round_2_send
      client.round_2_recv @gb

      # @key = Digest::SHA1.digest(0.to_s(16).from_hex)[0,16]
      @key = DH.derive_key(1, 0, @p)

      # # round 3
      @received_msg1 = DH.decrypt(client.round_3_send, @key)
      server.round_3_recv DH.encrypt(@received_msg1, @key)

      # # round 4
      @received_msg2 = DH.decrypt(server.round_4_send, @key)
      client.round_4_recv DH.encrypt(@received_msg2, @key)
    end
  end
end
