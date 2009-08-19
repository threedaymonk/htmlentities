# encoding: UTF-8
$KCODE = 'u' unless "1.9".respond_to?(:encoding)

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))
require "htmlentities"
require "benchmark"
require "profiler"

class HTMLEntitiesJob
  def initialize
    @coder = HTMLEntities.new
    @decoded = File.read(File.join(File.dirname(__FILE__), "sample"))
    @encoded = @coder.encode(@decoded, :basic, :named, :hexadecimal)
  end

  def encode(cycles)
    cycles.times do
      @coder.encode(@decoded, :basic, :named, :hexadecimal)
      @coder.encode(@decoded, :basic, :named, :decimal)
    end
  end

  def decode(cycles)
    cycles.times do
      @coder.decode(@encoded)
    end
  end

  def all(cycles)
    encode(cycles)
    decode(cycles)
  end
end

job = HTMLEntitiesJob.new
job.all(100) # Warm up to give JRuby a fair shake.

Benchmark.benchmark do |b|
  b.report("Encoding"){ job.encode(100) }
  b.report("Decoding"){ job.decode(100) }
end

puts "Encoding"
Profiler__::start_profile
job.encode(1)
Profiler__::print_profile($stdout)

puts "Decoding"
Profiler__::start_profile
job.decode(1)
Profiler__::print_profile($stdout)
