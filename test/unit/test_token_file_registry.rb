require 'helper'
require 'fakefs/safe'

module ParadeiserTest
  class TestTokenFileRegistry < MiniTest::Test
    def setup
# TODO
#      FakeFS.activate!
      @token_file_registry = TokenFileRegistry.new
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_write_cleanup
      assert(Dir.exist?(Dir.tmpdir))
      file = @token_file_registry.create
      assert(file)
      refute_empty(file)

      content = srand.to_s

      File.open(file, 'w+') do |f|
        f.write(content)
      end

      assert(File.exist?(file))
      assert_equal(content, File.read(file))

      file2 = @token_file_registry.create
      assert(file2)
      refute_empty(file2)
      refute(File.exist?(file2))

      @token_file_registry.cleanup
      refute(File.exist?(file))
    end
  end
end
