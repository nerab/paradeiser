require 'helper'
require 'ostruct'

class TestStatus < MiniTest::Test
  def test_pomodoro_active
    assert_equal(0, Status.new(thing('pomodoro', 'active')).to_i)
  end

  def test_pomodoro_finished
    assert_equal(1, Status.new(thing('pomodoro', 'finished')).to_i)
  end

  def test_break_active
    assert_equal(2, Status.new(thing('break', 'active')).to_i)
  end

  def test_break_finished
    assert_equal(3, Status.new(thing('break', 'finished')).to_i)
  end

  private

  def thing(name, status)
    OpenStruct.new(:name => name, :status => status)
  end
end
