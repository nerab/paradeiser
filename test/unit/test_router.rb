require 'helper'
require 'fakefs/safe'

class CommandMock < Struct.new(:name)
end

class TestRouter < MiniTest::Test
  def setup
    FakeFS.activate!
  end

  def teardown
    FakeFS.deactivate!
  end

  def test_init
    refute(Dir.exists?(Paradeiser.pom_dir), "Expect #{Paradeiser.pom_dir} to not exist yet")

    block = Router.new.dispatch(CommandMock.new('init'))
    refute_nil(block)

    refute(Dir.exists?(Paradeiser.pom_dir), "Expect #{Paradeiser.pom_dir} to not exist yet")

    # fake the view
    dirname = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'paradeiser', 'views', 'paradeiser')
    FileUtils.mkdir_p(dirname)
    view = File.join(dirname, 'init.erb')
    FileUtils.touch(view)

    begin
      block.call(nil, OptionsMock.new(:trace => true, :verbose => false))
    ensure
      FileUtils.rm_r(Paradeiser.pom_dir, :force => true)
    end
  end
end
