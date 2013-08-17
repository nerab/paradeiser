require 'helper'

class TestViewStatus < MiniTest::Test
  def test_report_0
    out, err = render(:report)
    assert_empty(err)
    assert(out)
    lines = out.lines
    assert_equal(7, lines.size)

    assert_equal('Pomodoro Report', lines[0].chomp)
    assert_empty(lines[1].chomp)

    assert_match(/^\d pomodori finished$/, lines[2].chomp)
    assert_equal('0', lines[2][0])

    assert_match(/^\d pomodori canceled$/, lines[3].chomp)
    assert_equal('0', lines[3][0])

    assert_match(/^\d internal interrupts$/, lines[4].chomp)
    assert_equal('0', lines[4][0])

    assert_match(/^\d external interrupts$/, lines[5].chomp)
    assert_equal('0', lines[5][0])

    assert_match(/^\d breaks \(\d minutes in total\)$/, lines[6].chomp)
    assert_equal('0', lines[6][0])
    assert_equal('0', lines[6][10])
  end

  def test_report_1
    @finished = 1
    @canceled = 1
    @external_interrupts = 1
    @internal_interrupts = 1
    @breaks = 1
    @break_minutes = 1

    out, err = render(:report)
    assert_empty(err)
    assert(out)
    lines = out.lines
    assert_equal(7, lines.size)

    assert_equal('Pomodoro Report', lines[0].chomp)
    assert_empty(lines[1].chomp)

    assert_match(/^\d pomodoro finished$/, lines[2].chomp)
    assert_equal('1', lines[2][0])

    assert_match(/^\d pomodoro canceled$/, lines[3].chomp)
    assert_equal('1', lines[3][0])

    assert_match(/^\d internal interrupt$/, lines[4].chomp)
    assert_equal('1', lines[4][0])

    assert_match(/^\d external interrupt$/, lines[5].chomp)
    assert_equal('1', lines[5][0])

    assert_match(/^\d break \(\d minute in total\)$/, lines[6].chomp)
    assert_equal('1', lines[6][0])
    assert_equal('1', lines[6][9])
  end

private

  def render(method)
    capture_io do
      View.new('Paradeiser', method).render(binding)
    end
  end
end
