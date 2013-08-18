require 'helper'

class TestBreaksController < ControllerTest
  def setup
    @backend = PStoreMock.new
  end

  def model
    'break'
  end

  def test_break
    attrs = invoke(:start, nil, nil, '@break', 'exitstatus', 'has_output')
    assert_equal(:active, attrs[:break].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_break_verbose
    attrs = invoke(:start, nil, OpenStruct.new(:verbose => true), '@break', 'exitstatus', 'has_output')
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
    attrs = invoke(:finish, nil, nil, '@break', 'exitstatus', 'has_output')
    assert_equal(:finished, attrs[:break].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_finish_verbose
    invoke(:start)
    attrs = invoke(:finish, nil, OpenStruct.new(:verbose => true), '@break', 'exitstatus', 'has_output')
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
end
