require 'helper'

class TestPomodoriController < MiniTest::Test
  def setup
    @backend = MockPStore.new
  end

  def test_start_active
    invoke(:start)

    assert_raises SingletonError do
      invoke(:start)
    end
  end

  def test_start
    out,err = invoke(:start)
    assert_match(/^Starting pomodoro #1\.$/m, out)
    assert_empty(err)
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:start)
    out,err = invoke(:finish)
    assert_match(/^Finished pomodoro #1 after .* minutes\.$/m, out)
    assert_empty(err)
    assert_equal(1, @backend.size)
    assert_equal(:finished, @backend[@backend.roots.first].status_name)
  end

  def test_finish_idle
    assert_raises NoActivePomodoroError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end

private

  def invoke(method, args = [], options = OpenStruct.new(:verbose => true))
    Repository.stub :backend, @backend do
      capture_io do
        PomodoriController.new(method).call(args, options)
      end
    end
  end
end
