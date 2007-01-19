require "rubygems"
require "rake/gempackagetask"
require "rake/testtask"
require "zlib"
require "rake/clean"
require './lib/htmlentities'

ENTITY_DATA_FILE = 'lib/htmlentities/data.rb'
CLEAN.include("doc")

SOURCES = FileList["lib/**/*.rb", ENTITY_DATA_FILE]

task :default => :test

spec = Gem::Specification.new do |s|
  s.name   = "htmlentities"
  s.version = HTMLEntities::VERSION
  s.author = "Paul Battley"
  s.email = "pbattley@gmail.com"
  s.summary = "A module for encoding and decoding (X)HTML entities."
  s.files = FileList['{lib,test}/**/*.rb', ENTITY_DATA_FILE]
  s.require_path = "lib"
  s.test_file = 'test/all.rb'
  s.has_rdoc = true
  s.extra_rdoc_files = %w[README.txt History.txt COPYING.txt]
  s.homepage = 'http://htmlentities.rubyforge.org/'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_gz = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

file ENTITY_DATA_FILE => %w[util/build_entities.rb] do |f|
  sh %{ruby util/build_entities.rb > #{f.name}}
end

file "doc" => SOURCES do |f|
  sh %{rdoc lib}
end
