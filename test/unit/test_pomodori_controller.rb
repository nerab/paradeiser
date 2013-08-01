require 'helper'

class TestPomodoriController < MiniTest::Test
  def setup
    @backend = MockPStore.new
  end

  def test_output_status_000 # flags are verbose, quiet, printing
    assert_output(false, false, false, false)
  end

  def test_output_status_001
    invoke(:start) # give the report something to report
    assert_output(true , false, false, true )
  end

  def test_output_status_010
    assert_output(false, false, true , false)
  end

  def test_output_status_011
    assert_output(false, false, true , true )
  end

  def test_output_status_100
    invoke(:start)
    assert_output(true , true , false, false)
  end

  def test_output_status_101
    invoke(:start)
    assert_output(true , true , false, true )
  end

  def test_output_status_110
    assert_output(false, true,  true , false)
  end

  def test_output_status_111
    assert_output(false, true,  true , true)
  end

  def test_status_active
    invoke(:start)
    out, err, status = invoke(:status, [], :verbose => false)
    assert_equal(0, status)
    assert_empty(err)
    assert_match(/^Pomodoro #1 is active \(started at .*\)\.$/m, out)
  end

  def test_status_finished
    invoke(:start)
    invoke(:finish)
    out, err, status = invoke(:status, [], :verbose => false)
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

  def invoke(method, args = [], options = {:verbose => true, :quiet => false})
    controller = PomodoriController.new(method)

    Repository.stub :backend, @backend do
      out, err = capture_io do
        controller.call(args, OpenStruct.new(options))
      end

      [out, err, controller.exitstatus]
    end
  end

  def assert_output(expected, verbose, quiet, printing, command = :report)
    out, _, _ = invoke(command, [], :verbose => false, :quiet => false)
    assert_equal(expected, !out.chomp.empty?, "Expect #{[verbose, quiet, printing]} to be #{expected}. Content was: '#{out}'")
  end
end
