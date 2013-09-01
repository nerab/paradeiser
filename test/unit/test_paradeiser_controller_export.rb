require 'helper'

#
# There is no view for export, so we need to test the entire results here
#
module ParadeiserTest
  class TestParadeiserControllerExport < ParadeiserControllerTest
    def setup
      super
      @backend = PStoreMock.new
    end

    def test_empty
      attrs = invoke(:export)
      assert_empty(attrs[:stderr])

      result = JSON.parse(attrs[:stdout])
      assert(result)
      assert_empty(result)
    end

    def test_pomodoro
      pom = produce(Pomodoro)
      started_at = Time.new(8)
      pom.started_at = started_at
      pom.finish!
      finished_at = Time.new(16)
      pom.finished_at = finished_at
      @backend[:bar] = pom

      attrs = invoke(:export)
      assert_empty(attrs[:stderr])
      result = JSON.parse(attrs[:stdout])

      assert(result)
      refute_empty(result)
      assert_equal(1, result.size)
      p = result.first
      assert(p)

      assert_equal('Pomodoro', p['type'])
      assert_equal(1500, p['length'])
      assert_equal('finished', p['status'])
      assert_equal(started_at.as_json, p['started_at'])
      assert_equal(finished_at.as_json, p['finished_at'])

      interrupts = p['interrupts']
      assert(interrupts)
      assert_empty(interrupts)

      annotations = p['annotations']
      assert(annotations)
      assert_empty(annotations)
    end

    def test_break
      br3ak = produce(Break)
      started_at = Time.new(8)
      br3ak.started_at = started_at
      br3ak.finish!
      finished_at = Time.new(16)
      br3ak.finished_at = finished_at
      @backend[:bar] = br3ak

      attrs = invoke(:export)
      assert_empty(attrs[:stderr])
      result = JSON.parse(attrs[:stdout])

      assert(result)
      refute_empty(result)
      assert_equal(1, result.size)
      p = result.first
      assert(p)

      assert_equal('Break', p['type'])
      assert_equal(300, p['length'])
      assert_equal('finished', p['status'])
      assert_equal(started_at.as_json, p['started_at'])
      assert_equal(finished_at.as_json, p['finished_at'])

      refute(p['interrupts'])
      refute(p['annotations'])
    end

    def test_multiple
      br3ak = produce(Break)
      br3ak.started_at = Time.new(8)
      br3ak.finish!
      br3ak.finished_at = Time.new(16)
      @backend[:bar] = br3ak

      pom = produce(Pomodoro)
      pom.started_at = Time.new(8)
      pom.finish!
      pom.finished_at = Time.new(16)
      @backend[:foo] = pom

      attrs = invoke(:export)
      assert_empty(attrs[:stderr])
      result = JSON.parse(attrs[:stdout])

      assert(result)
      refute_empty(result)
      assert_equal(2, result.size)

      assert_equal('Break', result.first['type'])
      assert_equal('Pomodoro', result.last['type'])
    end
  end
end
