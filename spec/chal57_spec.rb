describe Chal57 do
  let(:attacker) { Chal57::Attacker.new }
  let(:target) { Chal57::Client.new }
  let(:p) { Chal57::P }
  let(:g) { Chal57::G }
  let(:q) { Chal57::Q }
  let(:j) { (p-1) / q }

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
      expect(product_of_divisors).to be > q
    end
  end

  describe "hack" do
    let(:secret_key) { target.instance_eval{ @a } }
    let(:recovered_key) { attacker.hack(target) }
    it do
      expect(recovered_key).to eq(secret_key)
    end
  end
end
