module DSA
  class << self
    def p
      %W[
        800000000000000089e1855218a0e7dac38136ffafa72eda7
        859f2171e25e65eac698c1702578b07dc2a1076da241c76c6
        2d374d8389ea5aeffd3226a0530cc565f3bf6b50929139ebe
        ac04f48c3c84afb796d61e5a4f9a8fda812ab59494232c7d2
        b4deb50aa18ee9e132bfa85ac4374d7f9091abc3d015efc87
        1a584471bb1
      ].join.to_i(16)
    end

    def q
      %Q[f4f47f05794b256174bba6e9b396a7707e563c5b].to_i(16)
    end

    def g
      %W[
        5958c9d3898b224b12672c0b98e06c60df923cb8bc999d119
        458fef538b8fa4046c8db53039db620c094c9fa077ef389b5
        322a559946a71903f990f1f7e0e025e2d7f7cf494aff1a047
        0f5b64c36b625a097f1651fe775323556fe00b3608c887892
        878480e99041be601a62166ca6894bdd41a7054ec89f756ba
        9fc95302291
      ].join.to_i(16)
    end

    def validate_parameters(p, q, g)
      raise "p is not prime" unless OpenSSL::BN.new(p).prime?
      raise "q is not prime" unless OpenSSL::BN.new(q).prime?
      raise "p-1 is not multiple of q" unless (p-1) % q == 0
      # Is this full test?
      raise "g is not q-order generator of Gp" unless 1 != g and g.powmod(q, p) == 1
      true
    end
  end
end
