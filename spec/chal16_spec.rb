describe Chal16 do
  let(:chal) { Chal16.new }
  let(:box) { Chal16::Box.new }

  let(:admin_string) { chal.hack(box) }

  it do
    expect(box.decrypt(admin_string)).to include ";admin=true;"
  end
end
