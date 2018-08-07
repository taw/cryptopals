class Chal23
  def temper(y)
    y ^= ((y >> u) & d)
    y ^= ((y << s) & b)
    y ^= ((y << t) & c)
    y ^= (y >> l)
    y & 0xFFFF_FFFF
  end

  def equations
    bs = (0...32).map{ |i| temper(1 << i) }
    (0...32).map do |i|
      eq = (0...32).map{ |j| bs[j][i] == 1 ? "a[#{j}]" : nil }.compact.join(" ^ ")
      "b[#{i}] = #{eq}"
    end
  end

  def temper_by_equations(y)
    a = (0...32).map{|i| y[i]}
    b = (0...32).map{|i| 0 }
    eval(equations.join("\n"), binding)
    b.join.reverse.to_i(2)
  end

  def untemper(x)
    y = Z3::Bitvec("y", 32)
    expr = y
    expr ^= ((expr .unsigned_rshift u) & d)
    expr ^= ((expr << s) & b)
    expr ^= ((expr << t) & c)
    expr ^= (expr .unsigned_rshift l)
    expr = expr & 0xFFFF_FFFF
    solver = Z3::Solver.new
    solver.assert expr == x
    raise unless solver.satisfiable?
    solver.model[y].to_s.to_i
  end

  def clone(rng)
    numbers = n.times.map{ rng.extract_number }
    cloned_state = numbers.map{|x| untemper(x) }
    cloned_rng = Chal21.new
    cloned_rng.instance_eval do
      @index = n
      @x = cloned_state.dup
      @initialized = true
    end
    cloned_rng
  end

  ### Various constants, same as Chal21
  def w
    32
  end

  def n
    624
  end

  def m
    397
  end

  def r
    31
  end

  def a
    0x9908B0DF
  end

  def u
    11
  end

  def d
    0xFFFFFFFF
  end

  def s
    7
  end

  def b
    0x9D2C5680
  end

  def t
    15
  end

  def c
    0xEFC60000
  end

  def l
    18
  end

  def f
    1812433253
  end
end
