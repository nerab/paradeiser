# from Gem::TestCase rubygems/test_case.rb
def assert_path_exists(path, msg = nil)
  msg = message(msg){"Expected path '#{path}' to exist"}
  assert(File.exist?(path), msg)
end

def refute_path_exists(path, msg = nil)
  msg = message(msg){"Expected path '#{path}' to NOT exist"}
  refute(File.exist?(path), msg)
end
