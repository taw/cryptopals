describe GF2Matrix do
  it ".identity" do
    expect(GF2Matrix.identity(4)).to eq(GF2Matrix.new([1,2,4,8]))
  end

  it "+" do
    a = GF2Matrix.new([1, 2, 3, 5])
    b = GF2Matrix.new([10, 6, 14, 6])
    c = GF2Matrix.new([1^10, 2^6, 3^14, 5^6])
    expect(a+b).to eq(c)
  end

  it "* vector" do
    v = 10
    a = GF2Matrix.new([6, 7, 8, 9])
    expect(a*v).to eq(7 ^ 9)
  end

  it "* matrix" do
    a = GF2Matrix.random(4)
    b = GF2Matrix.random(4)
    v = rand(0..15)
    expect((a*b)*v).to eq(a*(b*v))
  end

  it "**" do
    a = GF2Matrix.random(4)
    expect(a**0).to eq(GF2Matrix.identity(4))
    expect(a**1).to eq(a)
    expect(a**7).to eq(a*a*a*a*a*a*a)
  end
end
