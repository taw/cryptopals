describe GCMPoly do
  let(:zero) { GCMField.zero }
  let(:one) { GCMField.one }
  let(:a) { GCMField.random }
  let(:b) { GCMField.random }
  let(:c) { GCMField.random }
  let(:d) { GCMField.random }
  let(:e) { GCMField.random }
  let(:f) { GCMField.random }
  let(:g) { GCMField.random }

  it "==" do
    expect(GCMPoly[a, b, c]).to eq(GCMPoly[a, b, c])
    expect(GCMPoly[a, b, c]).to_not eq(GCMPoly[d, e, f])
  end

  it "normalization" do
    expect(GCMPoly[a, b, c]).to eq(GCMPoly[a, b, c, zero, zero, zero])
  end

  it "eval" do
    expect(GCMPoly[a, b, c].eval(d)).to eq(a + b*d + c*d*d)
  end

  it "degree" do
    expect(GCMPoly[a, b, c].degree).to eq(2)
    expect(GCMPoly[a].degree).to eq(0)
    expect(GCMPoly[zero].degree).to eq(-1)
  end

  it "+" do
    expect(GCMPoly[a, b, c] + GCMPoly[d, e, f]).to eq(
      GCMPoly[a+d, b+e, c+f])
  end

  it "-" do
    expect(GCMPoly[a, b, c] - GCMPoly[d, e, f]).to eq(
      GCMPoly[a-d, b-e, c-f])
    expect(GCMPoly[a, b, c] - GCMPoly[d, e, f]).to eq(
           GCMPoly[a, b, c] + GCMPoly[d, e, f])
  end

  it "<<" do
    expect(GCMPoly[a, b, c] << 2).to eq(GCMPoly[zero, zero, a, b, c])
  end

  it ">>" do
    expect(GCMPoly[a, b, c] >> 2).to eq(GCMPoly[c])
  end

  it "to_monic" do
    expect(GCMPoly[a, b, c].to_monic).to eq(GCMPoly[a/c, b/c, one])
  end

  it "*" do
    expect(GCMPoly[a, b, c] * GCMPoly[d, e, f]).to eq(
      GCMPoly[
        a*d,
        a*e + b*d,
        a*f + b*e + c*d,
              b*f + c*e,
                    c*f,
      ]
    )
  end

  it "divmod" do
    u, v = GCMPoly[a,b,c,d], GCMPoly[e,f,g]
    q, r = u.divmod(v)
    expect(q * v + r).to eq(u)
  end

  it "/" do
    expect(GCMPoly[a,b,c] / GCMPoly[d,e]).to eq(
      (GCMPoly[a,b,c].divmod(GCMPoly[d,e]))[0]
    )
  end

  it "%" do
    expect(GCMPoly[a,b,c] % GCMPoly[d,e]).to eq(
      (GCMPoly[a,b,c].divmod(GCMPoly[d,e]))[1]
    )
  end
end
