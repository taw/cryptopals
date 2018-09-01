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

  let(:fa) { GCMPoly[a,one] }
  let(:fb) { GCMPoly[b,one] }
  let(:fc) { GCMPoly[c,one] }
  let(:fd) { GCMPoly[d,one] }
  let(:fz) { GCMPoly[GCMField.new(456),GCMField.new(123),one] }

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

  it "gcd" do
    expect(GCMPoly[a,one].gcd GCMPoly[b,one]).to eq GCMPoly[one]
    u = GCMPoly[a,one] * GCMPoly[b,one] * GCMPoly[c,one]
    v = GCMPoly[a,one] * GCMPoly[b,one] * GCMPoly[d,one] * GCMPoly[e,one]
    expect(u.gcd(v)).to eq GCMPoly[a,one] * GCMPoly[b,one]
  end

  it "formal_derivative" do
    u = GCMPoly[a, b, c, d, e]
    expect(u.formal_derivative).to eq(
      GCMPoly[b, c+c, d+d+d, e+e+e+e]
    )
  end

  it "sqrt" do
    u = GCMPoly[a]
    expect((u**2).sqrt).to eq(u)
    v = GCMPoly[a, b]
    expect((v**2).sqrt).to eq(v)
    w = GCMPoly[a, b, c]
    expect((w**2).sqrt).to eq(w)
  end

  describe "square_free_factorization" do
    it do
      u = fa*fa*b
      sff = u.square_free_factorization
      expect(sff.map(&:degree).sum).to eq u.degree
      expect(sff).to match_array([fa, fa, GCMPoly[b]])
    end

    it do
      u = fa * fa * fb * fc * d
      sff = u.square_free_factorization
      expect(sff.map(&:degree).sum).to eq u.degree
      expect(sff).to match_array([fa, fa, fb*fc, GCMPoly[d]])
    end

    it do
      u = fa**4 * fb**3 * fc**2 * fd * e
      sff = u.square_free_factorization
      expect(sff.map(&:degree).sum).to eq u.degree
      expect(sff).to match_array([
        fa, fa, fa, fa,
        fb, fb, fb,
        fc, fc,
        fd,
        GCMPoly[e]])
    end
  end

  describe "distinct_degree_factorization" do
    it do
      u = fa*fb
      ddf = u.distinct_degree_factorization
      expect(ddf).to match_array([
        [fa*fb, 1],
      ])
    end

    it do
      u = fz
      ddf = u.distinct_degree_factorization
      expect(ddf).to match_array([
        [fz, 2],
      ])
    end

    it do
      u = fa*fb*fc*fz
      ddf = u.distinct_degree_factorization
      expect(ddf).to match_array([
        [fa*fb*fc, 1],
        [fz, 2],
      ])
    end
  end

  it "equal_degree_factorization" do
    u = fa*fb*fc
    edf = u.equal_degree_factorization(1)
    expect(edf).to match_array([
      fa, fb, fc,
    ])
  end

  it "factorization" do
    u = fa*fb*fc*fc*fd*fd*fd*fz*e
    expect(u.factorization).to match_array([
      fa,
      fb,
      fc, fc,
      fd, fd, fd,
      fz,
      GCMPoly[e],
    ])
  end

  it "roots" do
    u = fa*fb*fc*fc*fd*fd*fd*fz*e
    expect(u.roots).to match_array([a, b, c, d])
    expect(u.roots_by_factorization).to match_array([a, b, c, d])
  end
end
