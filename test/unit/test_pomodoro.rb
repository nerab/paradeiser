require 'helper'

class TestPomodoro < MiniTest::Test
  def setup
    @pom = Pomodoro.new
  end

  def test_virgin
    assert_equal(:idle, @pom.status_name)
  end

  def test_finish_idle
    assert_raises StateMachine::InvalidTransition do
      @pom.finish!
    end
  end

  def test_finish
    @pom.start!
    assert_equal(:active, @pom.status_name)

    now = srand

    Time.stub :now, Time.at(now) do
      @pom.finish!
    end

    assert_equal(:finished, @pom.status_name)
    assert_equal(now, @pom.finished_at.to_i)
  end

  def test_finish_finished
    @pom.start!
    @pom.finish!
    assert_raises StateMachine::InvalidTransition do
      @pom.finish!
    end
  end

  def test_start
    now = srand

    Time.stub :now, Time.at(now) do
      @pom.start!
    end

    assert_equal(:active, @pom.status_name)
    assert_equal(now, @pom.started_at.to_i)
  end
end
