require 'helper'

module ParadeiserTest
  class TestParadeiserControllerStatus < ParadeiserControllerTest
    def setup
      super
      @backend = PStoreMock.new
    end

    def test_status_idle
      attrs = invoke(:status, nil, nil, 'exitstatus', 'has_output')
      assert_equal(-1, attrs[:exitstatus])
      assert_equal(true, attrs[:has_output])
      refute_empty(attrs[:stdout])
      assert_empty(attrs[:stderr])
      assert_equal(0, @backend.size)
    end

    def test_status_active_pom
      @backend[:foo] = SchedulableMock.new(
        :status => 'active',
        :status_name => :active,
        :active => true,
        :name => 'pomodoro',
        :remaining => 0,
        :started_at => Time.now)

      attrs = invoke(:status, nil, nil, '@pom', 'has_output', 'exitstatus')
      assert_equal(0, attrs[:exitstatus])
      assert_equal(:active, attrs[:pom].status_name)
      assert_equal(true, attrs[:has_output])
      refute_empty(attrs[:stdout])
      assert_empty(attrs[:stderr])
      assert_equal(1, @backend.size)
    end

    def test_status_finished_pom
      @backend[:foo] = SchedulableMock.new(
        :status => 'finished',
        :status_name => :finished,
        :finished => true,
        :name => 'pomodoro',
        :remaining => 0,
        :finished_at => Time.now)

      attrs = invoke(:status, nil, nil, '@pom', 'has_output', 'exitstatus')
      assert_equal(1, attrs[:exitstatus])
      assert_equal(:finished, attrs[:pom].status_name)
      assert_equal(true, attrs[:has_output])
      refute_empty(attrs[:stdout])
      assert_empty(attrs[:stderr])
      assert_equal(1, @backend.size)
    end

    def test_status_active_break
      @backend[:foo] = SchedulableMock.new(
        :status => 'active',
        :status_name => :active,
        :active => true,
        :name => 'break',
        :remaining => 0,
        :started_at => Time.now)

      attrs = invoke(:status, nil, nil, '@pom', 'has_output', 'exitstatus')
      assert_equal(2, attrs[:exitstatus])
      assert_equal(:active, attrs[:pom].status_name)
      assert_equal(true, attrs[:has_output])
      refute_empty(attrs[:stdout])
      assert_empty(attrs[:stderr])
      assert_equal(1, @backend.size)
    end

    def test_status_finished_break
      @backend[:foo] = SchedulableMock.new(
        :status => 'finished',
        :status_name => :finished,
        :finished => true,
        :name => 'break',
        :remaining => 0,
        :finished_at => Time.now)

      attrs = invoke(:status, nil, nil, '@pom', 'has_output', 'exitstatus')
      assert_equal(3, attrs[:exitstatus])
      assert_equal(:finished, attrs[:pom].status_name)
      assert_equal(true, attrs[:has_output])
      refute_empty(attrs[:stdout])
      assert_empty(attrs[:stderr])
      assert_equal(1, @backend.size)
    end
  end
end
