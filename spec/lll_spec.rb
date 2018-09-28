describe LLL do
  # elementwise map
  def map2(matrix, &block)
    matrix.map{|row| row.map(&block) }
  end

  describe "dot" do
    let(:u) { [1, 2, 3] }
    let(:v) { [4, 5, 6] }

    it do
      expect(LLL.dot(u,v)).to eq(1*4 + 2*5 + 3*6)
      expect(LLL.dot(u,v)).to eq(LLL.dot(v,u))
      expect(LLL.dot(u,u)).to eq(LLL.dotself(u))
    end
  end

  describe "proj" do
    let(:u) { [1, 2, 3] }
    let(:u5) { [5, 10, 15] }
    let(:v) { [3, 3, 0] }
    let(:w) { [0, 0, 5] }
    let(:z) { [0, 0, 0] }

    it "vector and itself (or its parallel) projects to itself" do
      expect(LLL.proj(u, u)).to eq(u)
      expect(LLL.proj(u5, u)).to eq(u)
      expect(LLL.proj(u, u5)).to eq(u5)
      expect(LLL.proj(u5, u5)).to eq(u5)
    end

    it "vector and zero projects to zero" do
      expect(LLL.proj(u, z)).to eq(z)
      expect(LLL.proj(z, u)).to eq(z)
      expect(LLL.proj(z, z)).to eq(z)
    end

    it "orthogonal nonzero vectors project to zero" do
      expect(LLL.proj(v, w)).to eq(z)
      expect(LLL.proj(w, v)).to eq(z)
    end

    it do
      uv = LLL.dot(u,v)
      uu = LLL.dot(u,u)
      vv = LLL.dot(v,v)
      expect(LLL.proj(u, v)).to eq([Rational(1*uv,uu), Rational(2*uv,uu), Rational(3*uv,uu)])
      expect(LLL.proj(v, u)).to eq([Rational(3*uv,vv), Rational(3*uv,vv), Rational(0*uv,vv)])
    end
  end

  # Wikipedia describes orthonormal version, but we're going for just orthogonal
  describe "gramschmidt" do
    let(:b) { [
      [1, 2, 2],
      [-1, 0, 2],
      [0, 0, 1],
    ] }
    let(:q) {
      map2(LLL.gramschmidt(b)) { |xi| xi == xi.to_i ? xi.to_i : xi }
    }
    it do
      (0..2).each do |i|
        expect(LLL.dot(q[i], q[i])).to_not eq(0)
        (0...i).each do |j|
          expect(LLL.dot(q[i], q[j])).to eq(0)
        end
      end
    end
  end

  describe "reduce" do
    let(:b) { [
      [  -2r,    0r,    2r,    0r],
      [ 1/2r,   -1r,    0r,    0r],
      [  -1r,    0r,   -2r,  1/2r],
      [  -1r,    1r,    1r,    2r],
    ] }
    let(:expected) { [
      [ 1/2r,   -1r,    0r,    0r],
      [  -1r,    0r,   -2r,  1/2r],
      [-1/2r,    0r,    1r,    2r],
      [-3/2r,   -1r,    2r,    0r],
    ] }

    it do
      expect(LLL.reduce(b)).to eq(expected)
    end
  end

  # n=22 -> 13s
  describe "performance" do
    it do
      n = 22
      x = 10**12
      b = n.times.map{ n.times.map{ rand(-x..x) } }
      t = Time.now
      q = LLL.reduce(b)
      # p Time.now-t
      # p b
      # p q
    end
  end
end
