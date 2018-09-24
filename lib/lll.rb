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
      raise "TODO"
    end
  end
end
