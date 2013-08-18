require 'helper'

class TestBreaksController < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_break
    attrs = invoke(:start, nil, '@break', 'exitstatus', 'has_output')
    assert_equal(:active, attrs[:break].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_break_verbose
    attrs = invoke(:start, OpenStruct.new(:verbose => true), '@break', 'exitstatus', 'has_output')
    assert_equal(:active, attrs[:break].status_name)
    assert_equal(false, attrs[:has_output])
    refute_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
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
    attrs = invoke(:finish, nil, '@break', 'exitstatus', 'has_output')
    assert_equal(:finished, attrs[:break].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_finish_verbose
    invoke(:start)
    attrs = invoke(:finish, OpenStruct.new(:verbose => true), '@break', 'exitstatus', 'has_output')
    assert_equal(:finished, attrs[:break].status_name)
    assert_equal(false, attrs[:has_output])
    refute_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_finish_idle
    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end
private

  def invoke(method, options = nil, *attributes)
    controller = BreaksController.new(method)

    stdout, stderr = Repository.stub :backend, @backend do
      Scheduler.stub(:add, nil) do
        Scheduler.stub(:clear, nil) do
          capture_io do
            controller.call(nil, options)
          end
        end
      end
    end

    result = Hash[attributes.map do |e|
      [e.split('@').last.to_sym, controller.get_binding.eval(e)]
    end]

    result[:stdout] = stdout
    result[:stderr] = stderr
    result
  end
end
