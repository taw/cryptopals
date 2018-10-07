describe Chal64 do
  it "gcm_mul_matrix" do
    a = rand(0...2**128)
    b = rand(0...2**128)
    ma = Chal64.gcm_mul_matrix(a)
    expect(ma*b).to eq((GCMField.new(a) * GCMField.new(b)).value)
  end

  it "gcm_square_matrix" do
    ms = Chal64.gcm_square_matrix
    a = rand(0...2**128)
    expect(ms*a).to eq((GCMField.new(a) * GCMField.new(a)).value)
  end

  pending
end
