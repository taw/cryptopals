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
        twist_curve = @curve.to_twist
        @first_pass = []
        # First pass, get stuff modulo small primes
        # Unfortunately every factor has two matches, k and tf-k
        #
        # On Weierstrass curve it's easy to do O(sqrt(n)) baby step giant step this
        point0 = @curve.random_twist_point
        key0 = @client.receive(point0)
        @attackable_twist_factors.each do |tf|
          # puts "HACKING #{tf}"
          point = twist_curve.multiply(point0, @twist_order / tf)
          key = twist_curve.multiply(key0, @twist_order / tf)
          found1, found2 = twist_curve.log_by_bsgs(point, key, tf)
          raise "Math doesn't work" unless found1 and found2
          first_pass << [tf, [found1, found2].uniq]
        end
        # puts "HAXED"
      end
      @first_pass
    end

    def second_pass_input
      @second_pass_input ||= begin
        first_pass.reduce do |(q1,k1), (q2,k2)|
          q = q1*q2
          k = k1.product(k2).map{ |k| Integer.chinese_remainder(k, [q1,q2]) }
          [q, k]
        end
      end
    end

    # Second pass, reduce 2^N possible matches to just 4 (related to factor of 4 in twist order ???)
    def second_pass
      unless @second_pass
        q, ks = second_pass_input
        # random_twist_point_of_order is actually not totally right for composites so just retry for wrong answer
        # Fortunately we can retry with narrower base
        #
        # It also looks like sometimes it just plain doesn't work, unclear why
        10.times do
          point = @curve.random_twist_point_of_order(@twist_order, q)
          key = @client.receive(point)
          ks = ks.select{ |k| @curve.ladder(point, k) == key }.sort
          if ks.size <= 4
            break
          else
            warn "#{ks.size} results - #{ks}"
          end
        end
        @second_pass = ks
      end
      @second_pass
    end

    def secret
      candidates = [0,1,2,3].flat_map{|i| second_pass.map{|x| x + i*@twist_order/4}}.uniq.sort

      # Not using twist, using honest point now!
      point = @curve.random_point
      key = @client.receive(point)

      result = candidates.find{|k| @curve.multiply(point, k) == key }
      return result if result

      raise "Attack failed"
    end
  end
end
