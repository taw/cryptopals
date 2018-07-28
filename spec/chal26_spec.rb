describe Chal26 do
  let(:chal) { Chal26.new }
  let(:box) { Chal26::Box.new }

  let(:admin_string) { chal.hack(box) }

  it do
    expect(box.decrypt(admin_string)).to include ";admin=true;"
  end
end
