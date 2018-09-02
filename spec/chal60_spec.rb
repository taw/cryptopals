describe Chal60 do
  let(:prime) { 233970423115425145524320034830162017933 }
  # v^2 = u^3 + 534*u^2 + u
  let(:montgomery_curve) { MontgomeryCurve.new(prime, 534, 1) }
  let(:weierstrass_curve) { WeierstrassCurve.new(prime, -95051, 11279326) }
  let(:order) { 29246302889428143187362802287225875743 }
  let(:u) { 4 }
  let(:v) { 85518893674295321206118380980485522083 }
  let(:x) { u + 178 }
  let(:y) { v }
  let(:g) { [x,y] }

  it "has correct order" do
    expect( montgomery_curve.ladder(u, order) ).to eq(0)
    expect( montgomery_curve.ladder(u, order+1) ).to eq(u)
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

  # All the hacking
  pending
end
