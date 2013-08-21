require 'helper'

#
# There is no view for export, so we need to test the entire results here
#
class TestParadeiserControllerExport < ParadeiserControllerTest
  def setup
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
    pom.started_at = Time.new(8)
    pom.finish!
    pom.finished_at = Time.new(16)
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
    assert_equal('0008-01-01T00:00:00+01:00', p['started_at'])
    assert_equal('0016-01-01T00:00:00+01:00', p['finished_at'])

    interrupts = p['interrupts']
    assert(interrupts)
    assert_empty(interrupts)

    annotations = p['annotations']
    assert(annotations)
    assert_empty(annotations)
  end

  def test_break
    br3ak = produce(Break)
    br3ak.started_at = Time.new(8)
    br3ak.finish!
    br3ak.finished_at = Time.new(16)
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
    assert_equal('0008-01-01T00:00:00+01:00', p['started_at'])
    assert_equal('0016-01-01T00:00:00+01:00', p['finished_at'])

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
