class Chal60
  # It uses Montgomery not Weierstrass curves, but internal logic is the same
  Client = Chal59::Client

  class Attacker
    def initialize(client, curve, twist_order, attackable_twist_factors)
      @client = client
      @curve = curve
      @twist_order = twist_order
      @attackable_twist_factors = attackable_twist_factors
      @attackable_twist_factors_product = @attackable_twist_factors.reduce{ |u,v| u*v }
    end

    def first_pass
      unless @first_pass
        @first_pass = []
        # First pass, get stuff modulo small primes
        # Unfortunately every factor has two matches, k and tf-k
        #
        # It's also really damn slow
        # even with a bunch of hacks to speed it up
        # On Weierstrass curve it's easy to do O(sqrt(n)) baby step giant step this
        @attackable_twist_factors.each do |tf|
          puts "HACKING #{tf}"
          point = @curve.random_twist_point_of_order(@twist_order, tf)
          key = @client.receive(point)
          found = @curve.each_multiple(point, tf-1){|x,i|
            break i if x == key
          }
          raise "Math doesn't work" unless found
          first_pass << [tf, [found, (tf-found)%tf].uniq]
        end
      end
      @first_pass
    end

    def second_pass_input
      @second_pass_input ||= begin
        first_pass.reduce do |(q1,k1),(q2,k2)|
          q = q1*q2
          k = k1.product(k2).map{ |k| Integer.chinese_remainder(k, [q1,q2]) }
          [q, k]
        end
      end
    end

    def second_pass
      unless @second_pass
        q, ks = second_pass_input
        # random_twist_point_of_order is actually not totally right for composites so just retry for wrong answer
        # Fortunately we can retry with narrower base
        #
        # It also looks like sometimes it just plain doesn't work, unclear why
        100.times do
          point = @curve.random_twist_point_of_order(@twist_order, q)
          key = @client.receive(point)
          result = ks.select{ |k| @curve.ladder(point, k) == key }.sort
          if result.size == 2
            @second_pass = result
          else
            ks = result
            # warn "#{result.size} results - #{result}"
          end
        end
        @second_pass = ks
      end
      @second_pass
    end

    def secret
      # Second pass, reduce 2^N possible matches to just 2
      binding.pry
    end
  end
end
