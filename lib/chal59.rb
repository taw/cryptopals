class Chal59
  class Client
    def initialize(group, base_point, order)
      @group = group
      @base_point = base_point
      @order = order
      @secret = rand(2...order)
      @public = @group.multiply(@base_point, @secret)
    end

    def public
      @public
    end

    def receive(partner_public)
      @key = @group.multiply(partner_public, @secret)
    end

    # For tests only
    def key
      @key
    end
  end
end
