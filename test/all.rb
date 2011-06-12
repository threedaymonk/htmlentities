(Dir["test/test_*.rb"] - ["test/test_all.rb"]).each{|x| require x }
