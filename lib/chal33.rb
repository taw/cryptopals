class Chal33
  def initialize(p, g)
    @p = p
    @g = g
  end

  def generate
    @secret = rand(@p)
    @g.powmod(@secret, @p)
  end

  def receive(msg)
    @key = msg.powmod(@secret, @p)
  end

  def key
    raise unless @key
    @key
  end
end
