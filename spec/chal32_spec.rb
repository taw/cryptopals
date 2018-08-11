describe Chal32 do
  let(:server) { Chal32::Server.new }
  let(:hack) { Chal32::Hack.new(10032) }

  # This is super messy as it's actually trying to do HTTP
  it do
    begin
      thr = Thread.new{
        Rack::Server.start(app: Chal32::Server.new, Port: 10032)
      }
      sleep 1
      expect(hack.hack).to eq("All your base are belong to us\n")
    ensure
      thr.kill
    end
  end
end
