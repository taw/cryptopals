describe Chal60 do
  let(:prime) { 233970423115425145524320034830162017933 }
  # v^2 = u^3 + 534*u^2 + u
  let(:montgomery_curve) { MontgomeryCurve.new(prime, 534, 1) }
  let(:weierstrass_curve) { WeierstrassCurve.new(prime, -95051, 11279326) }
  let(:order) { 233970423115425145498902418297807005944 }
  let(:u) { 4 }
  let(:v) { 85518893674295321206118380980485522083 }
  let(:x) { u + 178 }
  let(:y) { v }
  let(:g) { [x,y] }

  let(:twist_order) { 2 * prime + 2 - order }
  let(:twist_factors) { [ 2, 2, 11, 107, 197, 1621, 105143, 405373, 2323367, 1571528514013 ] }

  it "has correct order" do
    expect( montgomery_curve.ladder(u, order) ).to eq(0)
    expect( montgomery_curve.ladder(u, order+1) ).to eq(u)

    # Hasse's theorem
    expect((order - (prime+1)).abs <= 2 * (prime**0.5)).to be true
  end

  it "has correct twist_order" do
    expect(twist_order + order).to eq(2 * prime + 2)
    expect(twist_factors.reduce{|a,b| a*b}).to eq(twist_order)

    expect( montgomery_curve.ladder(6, twist_order) ).to eq(0)
    expect( montgomery_curve.ladder(6, twist_order+1) ).to eq(6)
  end

  it "maps point correctly between two curve formatss" do
    [0, 1, 2, 1000, 123456, order-2, order-1, order].each do |k|
      gkm = montgomery_curve.ladder(u, k)
      gkw = weierstrass_curve.multiply(g, k)
      if gkw == :infinity
        expect(gkm).to eq(0)
      else
        expect(gkm).to eq(gkw[0]-178)
        # v or -v
        expect(montgomery_curve.calculate_v(gkm)).to include(gkw[1])
      end
    end
  end

  it "can still be attacked by invalid numbers" do
    evil_u = 76600469441198017145391791613091732004
    expect(montgomery_curve.ladder(evil_u, 11)).to eq(0)
    expect(montgomery_curve.calculate_v(evil_u)).to eq(nil)
  end

  it "associated_weierstrass_curve" do
    expect(montgomery_curve.associated_weierstrass_curve).to eq(weierstrass_curve)
  end

  it "from and to weierstrass form" do
    10.times do
      x, y = weierstrass_curve.random_point
      expect(weierstrass_curve.valid?([x, y])).to eq true
      u, v = montgomery_curve.from_weierstrass(x, y)
      expect(montgomery_curve.valid?(u, v)).to eq true
      x1, y1 = montgomery_curve.to_weierstrass(u, v)
      expect([x1,y1]).to eq([x,y])
    end
  end

  it "random_point" do
    10.times do
      point = montgomery_curve.random_point
      expect(montgomery_curve.valid?(point)).to eq true
    end
  end

  it "random_twist_point" do
    10.times do
      point = montgomery_curve.random_twist_point
      expect(point).to match(1...prime)
      expect(montgomery_curve.valid?(point)).to eq false
    end
  end

  it "random_twist_point" do
    twist_factors.uniq.each do |q|
      10.times do
        q = twist_order
        point = montgomery_curve.random_twist_point_of_order(twist_order, q)
        expect(point).to match(1...prime)
        expect(montgomery_curve.valid?(point)).to eq false
        expect(montgomery_curve.ladder(point, q)).to eq(0)
      end
    end
  end

  # All the hacking
  pending
end
