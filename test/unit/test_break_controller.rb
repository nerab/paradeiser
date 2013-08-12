require 'helper'

class TestBreakController < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_break
    br3k, has_output = invoke(:break, '@pom', 'has_output')
    assert_equal(:break, br3k.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_break_active
    invoke(:break)
    assert_equal(1, @backend.size)

    assert_raises SingletonError do
      invoke(:break)
    end
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:break)
    br3ak, has_output = invoke(:finish, '@pom', 'has_output')
    assert_equal(:break_finished, br3ak.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_finish_idle
    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end

  def test_report_idle
    br3ak, has_output = invoke(:report, '@pom', 'has_output')
    assert_empty(br3ak)
    assert_equal(true, has_output)
  end

  def test_report_break
    invoke(:break)
    br3ak, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(1, br3ak.size)
    assert_equal(true, has_output)
  end

  def test_report_finished
    invoke(:break)
    invoke(:finish)
    invoke(:break)
    br3ak, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(2, br3ak.size)
    assert_equal(true, has_output)
  end

  def test_status_idle
    br3ak, has_output = invoke(:status, '@pom', 'has_output')
    assert_equal(:idle, br3ak.status_name)
    assert_equal(true, has_output)
    assert_equal(0, @backend.size)
  end

  def test_status_break
    invoke(:break)
    br3ak, has_output = invoke(:status, '@pom', 'has_output')
    assert_equal(:break, br3ak.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

  def test_status_finished
    invoke(:break)
    invoke(:finish)
    br3ak, has_output = invoke(:status, '@pom', 'has_output')
    assert_equal(:break_finished, br3ak.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

private

  def invoke(method, *attributes)
    controller = BreakController.new(method)

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
