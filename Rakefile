desc "Create files for challenge"
task "create", [:number] do |t, args|
  number = args[:number]
  raise unless number and number =~ /\A\d+\z/
  lib_file = Pathname("lib/chal#{number}.rb")
  spec_file = Pathname("spec/chal#{number}_spec.rb")

  if lib_file.exist?
    warn "Already exists: #{lib_file}"
  else
    lib_file.write("class Chal#{number}\nend\n")
  end

  if spec_file.exist?
    warn "Already exists: #{spec_file}"
  else
    spec_file.write("describe Chal#{number} do\nend\n")
  end
end

desc "Print done status"
task "status" do
  done = (1..64).select{|i|
    path=Pathname("#{__dir__}/spec/chal#{i}_spec.rb")
    path.exist? and path.read =~ /expect/
  }.to_set

  (1..64).each_slice(8).each do |slice|
    puts slice.map{|i|
      done.include?(i) ? "[%02d]" % i : "[  ]"
    }.join(" ")
  end

  puts ""
  puts "Total: #{done.size}/64 done"
end
