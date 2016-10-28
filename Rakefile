require "rspec/core/rake_task"
require "rake/clean"

CLEAN.include("doc")
DOCTYPES = %w[html4 xhtml1]
DATA_FILES = DOCTYPES.map{ |d| "lib/htmlentities/mappings/#{d}.rb" }
SOURCES = FileList["lib/**/*.rb"] - DATA_FILES

task :default => [:entities, :spec]

desc "Run the specs."
RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = false
end

DOCTYPES.each do |name|
  file "lib/htmlentities/mappings/#{name}.rb" do |f|
    sh %{ruby util/build_entities.rb #{name} > #{f.name}}
  end
end

file "doc" => SOURCES do |f|
  sh %{rdoc #{SOURCES.join(' ')}}
end

task :entities => DATA_FILES

desc "Run benchmark"
task :benchmark do |t|
  system "ruby -v"
  system "ruby perf/benchmark.rb"
end

desc "Use profiler to analyse encoding and decoding"
task :profile do |t|
  system "ruby -v"
  system "ruby perf/profile.rb"
end
