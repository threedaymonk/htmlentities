# encoding: UTF-8
$KCODE = 'u' unless "1.9".respond_to?(:encoding)

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))
require "htmlentities"
require "benchmark"

class HTMLEntitiesJob
  def initialize
    @coder = HTMLEntities.new
    @decoded = File.read(File.join(File.dirname(__FILE__), "sample"))
    @encoded = @coder.encode(@decoded, :basic, :named, :hexadecimal)
  end

  def run(cycles)
    cycles.times do
      @coder.encode(@decoded, :basic, :named, :hexadecimal)
      @coder.decode(@encoded)
    end
  end
end

job = HTMLEntitiesJob.new
job.run(100) # Warm up to give JRuby a fair shake.

Benchmark.benchmark do |b|
  b.report{ job.run(100) }
end
