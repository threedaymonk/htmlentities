$KCODE = "u" unless "1.9".respond_to?(:encoding)

require File.expand_path("../performance", __FILE__)
require "ruby-prof"

job = HTMLEntitiesJob.new

puts "Encoding"
encoding = RubyProf::Profile.new
encoding.start
job.encode(1)
RubyProf::FlatPrinter.new(encoding.stop).print $stdout

puts "Decoding"
decoding = RubyProf::Profile.new
decoding.start
job.decode(1)
RubyProf::FlatPrinter.new(decoding.stop).print $stdout
