class Chal32
  class Server
    def initialize
      @data = "All your base are belong to us\n"
      @key = Random.bytes(32)
      @mac = OpenSSL::HMAC.hexdigest("MD5", @key, @data)[0, 16]
      # For debugging:
      warn "MAC is #{@mac}"
    end

    def call(env)
      signature = Rack::Utils.parse_nested_query(env["QUERY_STRING"])["signature"] || ""
      if insecure_compare(@mac, signature)
        [200, {"Content-Type" => "text/plain"}, [@data]]
      else
        [500, {"Content-Type" => "text/plain"}, ["Bad MAC\n"]]
      end
    end

    def insecure_compare(a, b)
      i = 0
      while true
        # sleep 0.001 # 1ms - this usually works locally but not on CI
        sleep 0.005 # 5ms
        return false if a[i] != b[i]
        return true if a[i] == nil and b[i] == nil
        i += 1
      end
    end
  end

  class Hack
    def initialize(port)
      @port = port
    end

    def request(prefix)
      signature = prefix + "x" * (16 - prefix.size)
      uri = URI("http://localhost:#{@port}/test?file=foo&signature=#{signature}")
      tm1 = Time.now
      res = Net::HTTP.get_response(uri)
      tm2 = Time.now
      [((tm2-tm1) * 1000).round(3), res.code == "200", res.body]
    end

    def break_character(known_prefix)
      fails = 0
      while true
        responses = 16.times.map{ [] }
        # Go around 5 times to avoid clustering
        5.times do
          (0..15).map do |i|
           prefix = known_prefix + i.to_s(16)
            response = request(prefix)
            # It's OK, so don't bother with timing stuff
            return prefix if response[1]
            responses[i] << [*response, prefix]
          end
        end
        responses = responses.map(&:min)

        candidate = responses.max.last
        next_slowest = (responses - [responses.max]).max.first
        # Confirm
        response = 5.times.map{ request(candidate) }.min
        if response[0] > next_slowest
          return candidate
        else
          warn "Confirmation failed on #{known_prefix}, retrying"
          fails += 1
          # binding.pry if fails == 10
        end
      end
    end

    def hack
      prefix = ""
      16.times do
        prefix = break_character(prefix)
        warn "GOT: #{prefix}"
      end
      response = request(prefix)
      raise "Hack failed" unless response[1]
      response[2]
    end
  end
end
