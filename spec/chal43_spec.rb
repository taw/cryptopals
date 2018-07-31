describe Chal43 do
  describe "validate default parameters" do
    it do
      expect(DSA.validate_parameters(DSA.p, DSA.q, DSA.g)).to eq(true)
    end
  end
end
