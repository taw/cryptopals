class Chal62
  class BiasedPrivateKey < ECDSA::PrivateKey
    def sign(msg)
      k = rand(2...n) & ~0xff
      h = ECDSA.hash(msg)
      r = curve.multiply(g, k)[0] % n
      s = ((h + d*r) * k.invmod(n)) % n
      ECDSA::Signature.new(public_key, msg, r, s)
    end
  end

  class Box
    def initialize(private_key)
      @private_key = private_key
    end

    def random_message
      Random.bytes(32)
    end

    def call
      @private_key.sign(random_message)
    end

    def public_key
      @private_key.public_key
    end
  end

  class Attacker
    attr_reader :l, :pl, :q

    def initialize(box, l=8)
      @box = box
      @l = 8
      @pl = 2**@l
      @q = box.public_key.group.n
    end

    def signature_to_ut(signature)
      s = signature.s
      r = signature.r
      h = signature.h

      s2l = (s * pl) % q
      t = r.divide_modulo(s2l, q)
      u = h.divide_modulo(-s2l, q)
      [u, t]
    end

    def collect_ut_pairs(count)
      count.times.map{
        signature = @box.call
        [signature, *signature_to_ut(signature)]
      }
    end

    # Interpret everything as divided by @pl
    def uts_to_lll_matrix(q, us, ts)
      ct = 1
      cu = q
      count = us.size
      matrix = count.times.map{ [0] * (count + 2) }
      matrix << [*ts.map{|t| t*pl}, ct, 0]
      matrix << [*us.map{|u| u*pl}, 0, cu]
      count.times do |i|
        matrix[i][i] = q*pl
      end
      matrix
    end

    def prepare_lll_input(count)
      pairs = collect_ut_pairs(count)
      q = pairs[0][0].group.n
      us = pairs.map{|row| row[1] }
      ts = pairs.map{|row| row[2] }
      uts_to_lll_matrix(q, us, ts)
    end

    def lll_result(count)
      LLL.reduce(prepare_lll_input(count))
    end

    def attack(count)
      result = lll_result(count)
      target = q
      matching_row = result.find{|row| row[-1] == target}
      if matching_row
        (-matching_row[-2]) % q
      end
    end
  end
end
