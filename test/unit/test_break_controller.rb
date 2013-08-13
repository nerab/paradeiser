require 'helper'

class TestBreakController < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_break
    br3k, has_output = invoke(:start, '@break', 'has_output')
    assert_equal(:active, br3k.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_break_active
    invoke(:start)
    assert_equal(1, @backend.size)

    assert_raises SingletonError do
      invoke(:start)
    end
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:start)
    br3ak, has_output = invoke(:finish, '@break', 'has_output')
    assert_equal(:finished, br3ak.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_finish_idle
    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end
private

  def invoke(method, *attributes)
    controller = BreaksController.new(method)

    Repository.stub :backend, @backend do
      Scheduler.stub(:add, nil) do
        Scheduler.stub(:clear, nil) do
          controller.call(nil, nil)
        end
      end
    end

    attributes.map do |attribute|
      controller.get_binding.eval(attribute)
    end
  end
end