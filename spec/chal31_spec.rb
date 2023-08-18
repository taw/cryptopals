describe Chal31 do
  let(:server) { Chal31::Server.new }
  let(:hack) { Chal31::Hack.new(10031) }

  # This is super messy as it's actually trying to do HTTP
  it do
    begin
      thr = Thread.new{
        Rackup::Server.start(app: Chal31::Server.new, Port: 10031)
      }
      sleep 1
      expect(hack.hack).to eq("All your base are belong to us\n")
    ensure
      thr.kill
    end
  end
end
