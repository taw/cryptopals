class Chal37
  class Client_0 < Chal36::Client
    def round_1_send
      [@email, 0]
    end

    def round_3_send
      hash(0)
    end
  end

  class Client_N < Chal36::Client
    def round_1_send
      [@email, DH.nist_prime]
    end

    def round_3_send
      hash(0)
    end
  end

  class Client_2N < Chal36::Client
    def round_1_send
      [@email, 2*DH.nist_prime]
    end

    def round_3_send
      hash(0)
    end
  end

  Server = Chal36::Server
  Network = Chal36::Network
end
