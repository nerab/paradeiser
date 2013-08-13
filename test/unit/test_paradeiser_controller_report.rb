
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

