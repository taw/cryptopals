module LLL
  class << self
    def dot(u, v)
      raise unless u.size == v.size
      (0...u.size).map{|i| u[i] * v[i] }.sum
    end

    def dotself(u)
      u.map{|ui| ui*ui}.sum
    end

    # projection of v onto u
    def proj(u, v)
      uu = dotself(u)
      if uu == 0
        return [0] * u.size
      else
        vu = dot(v, u)
        u.map{|ui| Rational(ui * vu, uu) }
      end
    end

    def gramschmidt(b)
      q = []
      b.each_with_index do |row, i|
        result = row.dup
        i.times do |j|
          z = proj(q[j], row)
          result.size.times do |k|
            result[k] -= z[k]
          end
        end
        q << result
      end
      q
    end

    def update_gramschmidt(b, qorig, range)
      q = qorig.map(&:dup)

      range.each do |i|
        row = b[i]
        result = row.dup
        i.times do |j|
          z = proj(q[j], row)
          result.size.times do |k|
            result[k] -= z[k]
          end
        end
        q[i] = result
      end

      # assert_gramschmidt(b, q)
      q
    end

    def assert_gramschmidt(b, q)
      raise "GS incorrect" unless q == gramschmidt(b)
    end

    def reduce(b, delta=0.99)
      b = b.map(&:dup)
      q = gramschmidt(b)

      mu = proc do |i,j|
        u = q[j]
        uu = dotself(u)
        if uu == 0
          0
        else
          v = b[i]
          vu = dot(v, u)
          Rational(vu, uu)
        end
      end

      n = b.size
      k = 1

      while k < n
        (k-1).downto(0) do |j|
          mukj = mu[k,j]
          if mukj.abs > Rational(1,2)
            z = mukj.round
            bk = b[k]
            bj = b[j]
            n.times do |v|
              bk[v] = bk[v] - z*bj[v]
            end
            # assert_gramschmidt(b, q)
          end
        end

        qkp2 = dotself(q[k-1])
        qk2 = dotself(q[k])

        if qk2 >= (delta - mu[k, k-1]**2) * qkp2
          k += 1
        else
          b[k], b[k-1] = b[k-1], b[k]
          q = update_gramschmidt(b, q, (k-1)..k)
          k = [k-1, 1].max
        end
      end
      b
    end
  end
end
