class Chal57
  P = 7199773997391911030609999317773941274322764333428698921736339643928346453700085358802973900485592910475480089726140708102474957429903531369589969318716771
  Q = 236234353446506858198510045061214171961
  G = 4565356397095740655436854503483826832136106141639563487732438195343690437606117828318042418238184896212352329118608100083187535033402010599512641674644143

  # I'm not really seeing why same private key is reused for multiple sessions
  # instead of getting fresh one each time
  class Client
    def initialize
      @a = rand(2...Q)
    end

    # Final part of the session
    #
    # Before that we got ga, but since we ignore it anyway (it's 128 bit brute force to attack),
    # no need to simulate that part
    def call(gb)
      key = gb.powmod(@a, P)
      # msg doesn't need to be the same every time
      msg = "crazy flamboyant for the rap enjoyment"
      [msg, Chal57.hmac(key, msg)]
    end
  end

  class Attacker
    def small_divisors
      [5, 109, 7963, 8539, 20641, 38833, 39341, 46337, 51977, 54319, 57529]
    end

    def find_element_of_order(r)
      while true
        h = rand(2...P).powmod((P-1)/r, P)
        return h unless h == 1
      end
    end

    def hack(target)
      reminders = []
      small_divisors.each do |r|
        h = find_element_of_order(r)
        msg, t = target.call(h)
        found = false
        (0...r).each do |ai|
          key = h.powmod(ai, P)
          if Chal57.hmac(key, msg) == t
            found = true
            reminders << ai
            break
          end
        end
        raise "Something went wrong with the maths" unless found
      end
      Integer.chinese_remainder(reminders, small_divisors)
    end
  end

  def self.hmac(key, msg)
    OpenSSL::HMAC.hexdigest("SHA256", "#{key}", msg)
  end
end
