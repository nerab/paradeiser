require 'helper'

class TestPomodoriController < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_start
    pom, has_output = invoke(:start, nil, '@pom', 'has_output')
    assert_equal(:active, pom.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_start_active
    invoke(:start)
    assert_equal(1, @backend.size)

    assert_raises SingletonError do
      invoke(:start)
    end
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:start)
    pom, has_output = invoke(:finish, nil, '@pom', 'has_output')
    assert_equal(:finished, pom.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_finish_idle
    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end

  def test_finish_canceled
    invoke(:start)
    invoke(:cancel)
    assert_equal(1, @backend.size)

    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(1, @backend.size)
    assert_equal(:canceled, @backend[@backend.roots.first].status_name)
  end

  def test_interrupt_idle
    assert_raises NotActiveError do
      invoke(:interrupt)
    end
    assert_equal(0, @backend.size)
  end

  def test_interrupt_active
    invoke(:start)
    pom, has_output = invoke(:interrupt, OpenStruct.new, '@pom', 'has_output')
    assert_equal(:active, pom.status_name)

    interrupts = pom.interrupts
    refute_nil(interrupts)
    refute_empty(interrupts)
    assert_equal(1, interrupts.size)

    interrupt = interrupts.first
    refute_nil(interrupt)
    refute_nil(interrupt.created_at)
    assert_equal(:internal, interrupt.type)
  end

  def test_interrupt_active_internal
    invoke(:start)
    pom = invoke(:interrupt, OpenStruct.new(:internal => true), '@pom')
    interrupt = pom.interrupts.first
    assert_equal(:internal, interrupt.type)
  end

  def test_interrupt_active_external
    invoke(:start)
    pom = invoke(:interrupt, OpenStruct.new(:external => true), '@pom')
    interrupt = pom.interrupts.first
    assert_equal(:external, interrupt.type)
  end

  def test_interrupt_finished
    invoke(:start)
    invoke(:finish)
    assert_equal(1, @backend.size)

    assert_raises NotActiveError do
      invoke(:interrupt)
    end

    assert_equal(1, @backend.size)
  end

  def test_cancel_idle
    assert_raises NotActiveError do
      invoke(:cancel)
    end
    assert_equal(0, @backend.size)
  end

  def test_cancel_active
    invoke(:start)
    pom, has_output = invoke(:cancel, nil, '@pom', 'has_output')
    assert_equal(:canceled, pom.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_cancel_finished
    invoke(:start)
    invoke(:finish)
    assert_equal(1, @backend.size)

    assert_raises NotActiveError do
      invoke(:cancel)
    end

    assert_equal(1, @backend.size)
  end

  def test_cancel_again
    invoke(:start)
    invoke(:cancel)
    assert_equal(1, @backend.size)
    invoke(:start)
    assert_equal(2, @backend.size)
  end

private

  def invoke(method, options = nil, *attributes)
    controller = PomodoriController.new(method)

    Repository.stub :backend, @backend do
      Scheduler.stub(:add, nil) do
        Scheduler.stub(:clear, nil) do
          controller.call(nil, options)
        end
      end
    end

    result = attributes.map do |attribute|
      controller.get_binding.eval(attribute)
    end

    if 1 == result.size
      result.first
    else
      result
    end
  end
end
