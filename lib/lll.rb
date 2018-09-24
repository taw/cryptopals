module LLL
  class << self
    def dot(u, v)
      raise unless u.size == v.size
      result = 0
      u.size.times do |i|
        result += u[i] * v[i]
      end
      result
    end

    # projection of v onto u
    def proj(u, v)
      uu = dot(u, u)
      vu = dot(v, u)
      if uu == 0
        return [0] * u.size
      else
        u.map{|ui| Rational(ui * vu, uu) }
      end
    end

    def gramschmidt(b)
      q = []
      b.each_with_index do |row, i|
        result = row.dup
        (0...i).each do |j|
          qj = q[j]
          z = proj(qj, row)
          result.size.times do |k|
            result[k] -= z[k]
          end
        end
        q << result
      end
      q
    end

    def reduce(b, delta=0.99)
      b = b.map(&:dup)
      q = gramschmidt(b)
      mu = proc do |i,j|
        v = b[i]
        u = q[j]
        vu = dot(v,u)
        uu = dot(u,u)
        if uu == 0
          0
        else
          Rational(vu, uu)
        end
      end

      n = b.size
      k = 1

      while k < n
        (k-1).downto(0) do |j|
          if mu[k,j].abs > Rational(1,2)
            bk = b[k]
            bj = b[j]
            z = mu[k,j].round
            n.times do |v|
              bk[v] = bk[v] - z*bj[v]
            end
            q = gramschmidt(b)
          end
        end

        qkp2 = dot(q[k-1], q[k-1])
        qk2 = dot(q[k], q[k])

        if qk2 >= (delta - mu[k, k-1]**2) * qkp2
          k += 1
        else
          b[k], b[k-1] = b[k-1], b[k]
          q = gramschmidt(b)
          k = [k-1, 1].max
        end
      end
      b
    end
  end
end


