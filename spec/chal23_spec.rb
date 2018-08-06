describe Chal23 do
  let(:chal) { Chal23.new }

  # This is important part of analysis
  describe "temper_by_equations" do
    it do
      100.times do
        y = rand(2**32)
        expect(chal.temper_by_equations(y)).to eq(chal.temper(y))
      end
    end
  end
end
