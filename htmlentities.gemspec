lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "htmlentities/version"

spec = Gem::Specification.new do |s|
  s.name             = "htmlentities"
  s.version          = HTMLEntities::VERSION::STRING
  s.author           = "Paul Battley"
  s.email            = "pbattley@gmail.com"
  s.summary          = "A module for encoding and decoding (X)HTML entities."
  s.files            = Dir["{lib,test,perf}/**/*.rb"]
  s.require_path     = "lib"
  s.test_files       = Dir["test/*_test.rb"]
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[History.txt COPYING.txt]
  s.homepage         = "https://github.com/threedaymonk/htmlentities"
end
