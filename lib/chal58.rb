class Chal58
  P = 11470374874925275658116663507232161402086650258453896274534991676898999262641581519101074740642369848233294239851519212341844337347119899874391456329785623
  Q = 335062023296420808191071248367701059461
  G = 622952335333961296978159266084741085889881358738459939978290179936063635566740258555167783009058567397963466103140082647486611657350811560630587013183357

  class Client
    def initialize
      @a = rand(2...Q)
    end

    def ga
      G.powmod(@a, P)
    end

    def call(gb)
      key = gb.powmod(@a, P)
      # msg doesn't need to be the same every time
      msg = "crazy flamboyant for the rap enjoyment"
      [msg, Chal58.hmac(key, msg)]
    end
  end

  class Attacker
    def small_divisors
      [2, 12457, 14741, 18061, 31193, 33941, 63803]
    end

    def product_of_small_divisors
      small_divisors.reduce{|u,v| u*v}
    end

    def find_element_of_order(r)
      while true
        h = rand(2...P).powmod((P-1)/r, P)
        return h unless h == 1
      end
    end

    def hack_partial_key(target)
      reminders = []
      small_divisors.each do |r|
        h = find_element_of_order(r)
        msg, t = target.call(h)
        found = false
        (0...r).each do |ai|
          key = h.powmod(ai, P)
          if Chal58.hmac(key, msg) == t
            found = true
            reminders << ai
            break
          end
        end
        raise "Something went wrong with the maths" unless found
      end
      Integer.chinese_remainder(reminders, small_divisors)
    end

    def hack(target)
      r = product_of_small_divisors
      n = hack_partial_key(target)
      g_minus_n = G.powmod(n, P).invmod(P)
      g_r = G.powmod(r, P)
      m_range = (0..((Q-1)/r))
      g_a = target.ga

      g_a_minus_n = (g_a * g_minus_n) % P

      m, i = KangarooDiscreteLogarithm.log(g_r, g_a_minus_n, P, m_range.min, m_range.max)
      [m*r + n, i]
    end
  end

  def self.hmac(key, msg)
    OpenSSL::HMAC.hexdigest("SHA256", "#{key}", msg)
  end
end
