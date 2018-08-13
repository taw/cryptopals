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

    def key
      @key
    end

    private def secret
      @secret
    end
  end

  class Attacker
    def initialize(client, *attack_data)
      @client = client
      @attack_data = []
      attack_data.each_slice(3) do |group, order, attack_list|
        attack_list.each do |factor|
          @attack_data << [group, order, factor]
        end
      end
    end

    def secret
      # HACK HACK HACK HACK!!!
      mods = []
      residues = []
      @attack_data.each do |group, order, factor|
        point = group.random_point_of_order(order, factor)
        @client.receive(point)
        key = @client.key
        pt = :infinity
        found = nil
        (0...factor).each do |i|
          if pt == key
            found = i
            break
          end
          pt = group.add(pt, point)
        end
        raise "Math is broken" unless found
        mods << factor
        residues << found
      end
      Integer.chinese_remainder(residues, mods)
    end
  end
end
