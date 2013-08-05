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
      finish!
    end
  end

  def test_finish
    start!
    assert_equal(:active, @pom.status_name)

    now = srand

    Time.stub :now, Time.at(now) do
      finish!
    end

    assert_equal(:finished, @pom.status_name)
    assert_equal(now, @pom.finished_at.to_i)
  end

  def test_duration_idle
    assert_equal(0, @pom.duration)
  end

  def test_duration_started
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      assert_equal(later - now, @pom.duration)
    end
  end

  def test_duration_finished
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      finish!
    end

    assert_equal(later - now, @pom.duration)
  end

  def test_finish_finished
    start!
    finish!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
  end

  def test_start
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    assert_equal(:active, @pom.status_name)
    assert_equal(now, @pom.started_at.to_i)
  end

  def test_remaining
    now = srand

    Time.stub :now, Time.at(now) do
      start!
      assert_equal(Pomodoro::LENGTH_SECONDS, @pom.remaining)
    end

    delta = 600
    later = now + delta

    Time.stub :now, Time.at(later) do
      assert_equal(Pomodoro::LENGTH_SECONDS - delta, @pom.remaining)
    end
  end
end
