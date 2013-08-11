require 'helper'

class TestBreak < MiniTest::Test
  def setup
    @pom = Break.new
  end

  def test_virgin
    assert_equal(:idle, @pom.status_name)
  end

  def test_break
    break!
    assert_equal(:break, @pom.status_name)
  end

  def test_finish_idle
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
  end

  def test_finish_break
    break!
    assert_equal(:break, @pom.status_name)

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

  def test_duration
    now = srand

    Time.stub :now, Time.at(now) do
      break!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      assert_equal(later - now, @pom.duration)
    end
  end

  def test_duration_finished
    now = srand

    Time.stub :now, Time.at(now) do
      break!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      finish!
    end

    assert_equal(later - now, @pom.duration)
  end

  def test_finish_break
    break!
    finish!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
  end

  def test_remaining
    now = srand

    Time.stub :now, Time.at(now) do
      break!
      assert_equal(@pom.length, @pom.remaining)
    end

    delta = 120
    later = now + delta

    Time.stub :now, Time.at(later) do
      assert_equal(@pom.length - delta, @pom.remaining)
    end
  end
end
