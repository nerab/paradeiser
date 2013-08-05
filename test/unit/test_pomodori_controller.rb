require 'helper'

class TestPomodoriController < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_start
    pom, has_output = invoke(:start, '@pom', 'has_output')
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
    pom, has_output = invoke(:finish, '@pom', 'has_output')
    assert_equal(:finished, pom.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_finish_idle
    assert_raises NoActivePomodoroError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end

  def test_report_idle
    pomodori, has_output = invoke(:report, '@pom', 'has_output')
    assert_empty(pomodori)
    assert_equal(true, has_output)
  end

  def test_report_active
    invoke(:start)
    pomodori, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(1, pomodori.size)
    assert_equal(true, has_output)
  end

  def test_report_finished
    invoke(:start)
    invoke(:finish)
    invoke(:start)
    pomodori, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(2, pomodori.size)
    assert_equal(true, has_output)
  end

  def test_status_idle
    pom, has_output = invoke(:status, '@pom', 'has_output')
    assert_equal(:idle, pom.status_name)
    assert_equal(true, has_output)
    assert_equal(0, @backend.size)
  end

  def test_status_active
    invoke(:start)
    pom, has_output = invoke(:status, '@pom', 'has_output')
    assert_equal(:active, pom.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

  def test_status_finished
    invoke(:start)
    invoke(:finish)
    pom, has_output = invoke(:status, '@pom', 'has_output')
    assert_equal(:finished, pom.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

private

  def invoke(method, *attributes)
    controller = PomodoriController.new(method)

    Repository.stub :backend, @backend do
      Scheduler.stub(:add, nil) do
        controller.call(nil, nil)
      end
    end

    attributes.map do |attribute|
      controller.get_binding.eval(attribute)
    end
  end
end
