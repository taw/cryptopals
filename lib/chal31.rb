class Chal31
  class Server
    def initialize
      @data = "All your base are belong to us\n"
      @key = Random::DEFAULT.bytes(32)
      @mac = OpenSSL::HMAC.hexdigest("MD5", @key, @data)[0, 16]
      # For debugging:
      warn "MAC is #{@mac}"
    end

    def call(env)
      signature = Rack::Utils.parse_nested_query(env["QUERY_STRING"])["signature"] || ""
      if insecure_compare(@mac, signature)
        [200, {"Content-Type" => "text/plain"}, @data]
      else
        [500, {"Content-Type" => "text/plain"}, "Bad MAC\n"]
      end
    end

    def insecure_compare(a, b)
      i = 0
      while true
        sleep 0.02
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
      while true
        responses = (0..15).map do |i|
          prefix = known_prefix + i.to_s(16)
          response = request(prefix)
          # It's OK, so don't bother with timing stuff
          return prefix if response[1]
          [*response, prefix]
        end
        candidate = responses.max.last
        next_slowest = (responses - [responses.max]).max.first
        # Confirm
        response = request(candidate)
        if response[0] > next_slowest
          return candidate
        else
          warn "Confirmation failed on #{known_prefix}, retrying"
        end
      end
    end

    # Req time is, 32 char MAC (MD5):
    # * request - kt or (k+1)t
    # * character - (16k+1)t
    # * mac - 16 * 8480 * t = almost 2h

    def hack
      prefix = ""
      16.times do
        prefix = break_character(prefix)
        # warn "GOT: #{prefix}"
      end
      response = request(prefix)
      raise "Hack failed" unless response[1]
      response[2]
    end
  end
end
