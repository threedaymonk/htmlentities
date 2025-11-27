lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "htmlentities/version"

Gem::Specification.new do |s|
  s.name = "htmlentities"
  s.version = HTMLEntities::VERSION::STRING
  s.author = "Paul Battley"
  s.email = "pbattley@gmail.com"
  s.description = "A module for encoding and decoding (X)HTML entities."
  s.summary = "Encode/decode HTML entities"
  s.files = Dir["lib/**/*.rb"]
  s.license = "MIT"
  s.require_path = "lib"
  s.extra_rdoc_files = %w[History.txt COPYING.txt]
  s.homepage = "https://github.com/threedaymonk/htmlentities"
  s.required_ruby_version = ">= 2.7.0"
  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "benchmark"
  s.add_development_dependency "ruby-prof"
end
