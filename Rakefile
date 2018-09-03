require "pathname"
require "paint"

task "default" => "status"

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
  started = Set[]
  done = Set[]
  (1..64).each do |i|
    path = Pathname("#{__dir__}/spec/chal#{i}_spec.rb")
    if path.exist?
      started << i
      done << i if path.read =~ /expect/ and path.read !~ /pending/
    end
  end

  (1..64).each_slice(8).each do |slice|
    puts slice.map{|i|
      if done.include?(i)
        Paint["[%02d]" % i, :green]
      elsif started.include?(i)
        Paint["[..]", :yellow ]
      else
        "[  ]"
      end
    }.join(" ")
  end

  puts ""
  puts "Total: #{done.size}/64 done"
end
