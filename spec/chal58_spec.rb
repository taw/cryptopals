describe Chal58 do
  let(:attacker) { Chal58::Attacker.new }
  let(:target) { Chal58::Client.new }
  let(:p) { Chal58::P }
  let(:g) { Chal58::G }
  let(:q) { Chal58::Q }
  let(:j) { (p-1) / q }

  describe "Kangaroo Log" do
    let(:kangaroo) { KangarooDiscreteLogarithm.log(g, y, p, range.min, range.max) }
    let(:k) { kangaroo[0] }
    let(:i) { kangaroo[1] }
    let(:gk) { g.powmod(k, p) }

    describe "20 bit hack" do
      let(:range) { 0..(2**20) }
      let(:y) { 7760073848032689505395005705677365876654629189298052775754597607446617558600394076764814236081991643094239886772481052254010323780165093955236429914607119 }

      it do
        # puts "Took #{i} trials for 20 bits"
        expect(gk).to eq(y)
      end
    end


    describe "30 bit hack" do
      let(:range) { 0..(2**30) }
      let(:y) { g.powmod(rand(range), p) }

      it do
        # puts "Took #{i} trials for 30 bits"
        expect(gk).to eq(y)
      end
    end

    describe "40 bit hack" do
      let(:range) { 0..(2**40) }
      let(:y) { 9388897478013399550694114614498790691034187453089355259602614074132918843899833277397448144245883225611726912025846772975325932794909655215329941809013733 }

      it do
        # puts "Took #{i} trials for 40 bits"
        expect(gk).to eq(y)
      end
    end
  end

  describe "group" do
    it "is valid" do
      expect(g.powmod(q, p)).to eq(1)
      expect(j * q).to eq(p - 1)
    end
  end

  describe "divisors" do
    let(:divisors) { attacker.small_divisors }
    let(:product_of_divisors) { divisors.reduce{|u,v| u*v} }
    it do
      divisors.each do |divisor|
        expect(divisor).to be_prime
        expect(j % divisor).to eq(0)
      end
      # That's different from Chal 57
      expect(product_of_divisors).to be < q
      expect(product_of_divisors).to eq(attacker.product_of_small_divisors)
    end
  end

  describe "hack" do
    let(:secret_key) { target.instance_eval{ @a } }
    let(:partial_recovered_key) { attacker.hack_partial_key(target) }
    it do
      expect(partial_recovered_key).to eq(secret_key % attacker.product_of_small_divisors)
    end
  end

  # Hack
  pending
end
