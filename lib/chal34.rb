class Chal34
  module DH
    class << self
      def nist_prime
        " ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024
          e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd
          3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec
          6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f
          24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361
          c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552
          bb9ed529077096966d670c354e4abc9804f1746c08ca237327fff
          fffffffffffff
        ".split.join.to_i(16)
      end

      def derive_key(secret, received_public, p)
        s = received_public.powmod(secret, p)
        Digest::SHA1.digest(s.to_s(16).from_hex)[0,16]
      end

      def encrypt(msg, key)
        iv = AES.random_key
        [iv, AES.encrypt_cbc(msg, key, iv)]
      end

      def decrypt(msg, key)
        iv, ct = msg
        AES.decrypt_cbc(ct, key, iv)
      end
    end
  end

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
    def call(client, server)
      # ...
    end
  end

  class ParameterInjectionMitmNetwork
    def call(client, server)
      # ...
    end
  end
end
