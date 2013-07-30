require 'helper'

class TestPomodoriController < MiniTest::Test
  def setup
    @backend = MockPStore.new
  end

  def test_status_active
    invoke(:start)
    out, err, status = invoke(:status)
    assert_equal(0, status)
    assert_empty(err)
    assert_match(/^Pomodoro #1 is active \(started at .*\)\.$/m, out)
  end

  def test_status_finished
    invoke(:start)
    invoke(:finish)
    out, err, status = invoke(:status)
    assert_equal(1, status)
    assert_empty(err)
    assert_match(/^No active pomodoro. Last one was finished at .*\.$/m, out)
  end

  def test_start_active
    invoke(:start)

    assert_raises SingletonError do
      invoke(:start)
    end
  end

  def test_start
    out, err, status = invoke(:start)
    assert_equal(0, status)
    assert_match(/^Starting pomodoro #1\.$/m, out)
    assert_empty(err)
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:start)
    out, err, status = invoke(:finish)
    assert_equal(0, status)
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

  def invoke(method, args = [], options = {:verbose => true})
    controller = PomodoriController.new(method)

    Repository.stub :backend, @backend do
      out, err = capture_io do
        controller.call(args, OpenStruct.new(options))
      end

      [out, err, controller.exitstatus]
    end
  end
end
