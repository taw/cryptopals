describe Chal60 do
  let(:prime) { 233970423115425145524320034830162017933 }
  # v^2 = u^3 + 534*u^2 + u
  let(:montgomery_curve) { Chal60::MontgomeryCurve.new(prime, 534, 1) }
  let(:weierstrass_curve) { ECC.new(prime, -95051, 11279326) }
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

   it "maps point correctly" do
    [0, 1, 123456, order-2, order-1, order].each do |k|
      gkm = montgomery_curve.ladder(u, k)
      gkw = weierstrass_curve.multiply(g, k)
      if gkw == :infinity
        expect(gkm).to eq(0)
      else
        expect(gkm).to eq(gkw[0]-178)
      end
    end
  end

  # All the hacking
  pending
end
