class Chal45
  Group0 = DSA::Group.new(DSA::Standard.p, DSA::Standard.q, 0)
  GroupP1 = DSA::Group.new(DSA::Standard.p, DSA::Standard.q, DSA::Standard.p+1)
end
