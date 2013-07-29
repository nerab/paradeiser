require 'helper'

class TestPomodoroController < MiniTest::Test
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
    invoke(:start)
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:start)
    invoke(:finish)
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

  def invoke(method, args = [], options = {})
    Repository.stub :backend, @backend do
      PomodoroController.new(method).call(args, options)
    end
  end
end
