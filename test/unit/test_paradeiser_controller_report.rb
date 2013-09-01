require 'helper'

module ParadeiserTest
  class TestParadeiserControllerReportTest < ParadeiserControllerTest
    ATTR_NAMES = %w{has_output @finished @canceled @external_interrupts @internal_interrupts @breaks @break_minutes}

    def setup
      super
      @backend = PStoreMock.new
    end

    def test_idle
      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(0, attrs[:finished])
    end

    def test_has_output
      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(true, attrs[:has_output])
    end

    def test_finished
      pom = produce(Pomodoro) # can't use mocks as long as the controller uses kind_of?
      pom.started_at = Time.new(8)
      pom.finished_at = Time.new(16)
      pom.finish!
      @backend[:bar] = pom

      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(1, attrs[:finished])
    end

    def test_canceled
      pom = produce(Pomodoro)
      pom.started_at = Time.new(16)
      pom.canceled_at = Time.new(24)
      pom.cancel!
      @backend[:bar] = pom

      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(1, attrs[:canceled])
    end

    def test_external_interrupts
      pom = produce(Pomodoro)
      pom.started_at = Time.new(24)
      pom.canceled_at = Time.new(32)
      pom.interrupt!(:external)
      @backend[:bar] = pom

      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(1, attrs[:external_interrupts])
    end

    def test_internal_interrupts
      pom = produce(Pomodoro)
      pom.started_at = Time.new(32)
      pom.canceled_at = Time.new(64)
      pom.interrupt!(:internal)
      @backend[:bar] = pom

      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(1, attrs[:internal_interrupts])
    end

    def test_breaks
      br3ak = produce(Break)
      br3ak.started_at = Time.new(164)
      br3ak.finished_at = Time.new(128)
      @backend[:foo] = br3ak

      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(1, attrs[:breaks])
    end

    def test_break_minutes
      @backend[:foo] = make_break(5)
      @backend[:bar] = make_break(3)
      @backend[:baz] = make_break(2)

      attrs = invoke(:report, nil, nil, *ATTR_NAMES)
      assert_equal(10, attrs[:break_minutes])
    end

  private

    def make_break(minutes = 5)
      Break.new.tap do |b|
        b.started_at = srand
        b.finished_at = b.started_at + minutes * 60
      end
    end
  end
end
