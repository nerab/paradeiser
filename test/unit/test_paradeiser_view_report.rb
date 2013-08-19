require 'helper'

class TestParadeiserViewReport < ParadeiserViewTest

  def setup
    @annotations = []
  end

  def test_report_0
    out = render(:report)
    assert(out)
    lines = out.lines
    assert_equal(6, lines.size)

    i = 0
    assert_equal('# Pomodoro Report', lines[i].chomp)

    i += 1
    assert_match(/^- \d pomodori finished$/, lines[i].chomp)
    assert_equal('0', lines[i][2])

    i += 1
    assert_match(/^- \d pomodori canceled$/, lines[i].chomp)
    assert_equal('0', lines[i][2])

    i += 1
    assert_match(/^- \d internal interrupts$/, lines[i].chomp)
    assert_equal('0', lines[i][2])

    i += 1
    assert_match(/^- \d external interrupts$/, lines[i].chomp)
    assert_equal('0', lines[i][2])

    i += 1
    assert_match(/^- \d breaks \(\d minutes in total\)$/, lines[i].chomp)
    assert_equal('0', lines[i][2])
    assert_equal('0', lines[i][12])
  end

  def test_report_1
    @finished = 1
    @canceled = 1
    @external_interrupts = 1
    @internal_interrupts = 1
    @breaks = 1
    @break_minutes = 1

    out = render(:report)
    assert(out)
    lines = out.lines
    assert_equal(6, lines.size)

    i = 0
    assert_equal('# Pomodoro Report', lines[i].chomp)

    i += 1
    assert_match(/^- \d pomodoro finished$/, lines[i].chomp)
    assert_equal('1', lines[i][2])

    i += 1
    assert_match(/^- \d pomodoro canceled$/, lines[i].chomp)
    assert_equal('1', lines[i][2])

    i += 1
    assert_match(/^- \d internal interrupt$/, lines[i].chomp)
    assert_equal('1', lines[i][2])

    i += 1
    assert_match(/^- \d external interrupt$/, lines[i].chomp)
    assert_equal('1', lines[i][2])

    i += 1
    assert_match(/^- \d break \(\d minute in total\)$/, lines[i].chomp)
    assert_equal('1', lines[i][2])
    assert_equal('1', lines[i][11])
  end

  def test_report_2
    @finished = 2
    @canceled = 2
    @external_interrupts = 2
    @internal_interrupts = 2
    @breaks = 2
    @break_minutes = 2

    out = render(:report)
    assert(out)
    lines = out.lines
    assert_equal(6, lines.size)

    i = 0
    assert_equal('# Pomodoro Report', lines[i].chomp)

    i += 1
    assert_match(/^- \d pomodori finished$/, lines[i].chomp)
    assert_equal('2', lines[i][2])

    i += 1
    assert_match(/^- \d pomodori canceled$/, lines[i].chomp)
    assert_equal('2', lines[i][2])

    i += 1
    assert_match(/^- \d internal interrupts$/, lines[i].chomp)
    assert_equal('2', lines[i][2])

    i += 1
    assert_match(/^- \d external interrupts$/, lines[i].chomp)
    assert_equal('2', lines[i][2])

    i += 1
    assert_match(/^- \d breaks \(\d minutes in total\)$/, lines[i].chomp)
    assert_equal('2', lines[i][2])
    assert_equal('2', lines[i][12])
  end

  def test_report_annotations
    @annotations = ['seven eleven', 'fourty two', 'something real']

    out = render(:report)
    assert(out)
    lines = out.lines
    assert_equal(11, lines.size)

    i = 7
    assert_equal('## Annotations', lines[i].chomp)

    i += 1
    @annotations.each_with_index do |annotation, ai|
      assert_equal("* #{annotation}", lines[i + ai].chomp)
    end
  end
end
