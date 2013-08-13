
  def test_report_idle
    br3ak, has_output = invoke(:report, '@break', 'has_output')
    assert_empty(br3ak)
    assert_equal(true, has_output)
  end

  def test_report_break
    invoke(:start)
    br3ak, has_output = invoke(:report, '@break', 'has_output')
    assert_equal(1, br3ak.size)
    assert_equal(true, has_output)
  end

  def test_report_finished
    invoke(:start)
    invoke(:finish)
    invoke(:start)
    br3ak, has_output = invoke(:report, '@break', 'has_output')
    assert_equal(2, br3ak.size)
    assert_equal(true, has_output)
  end

  def test_status_idle
    br3ak, has_output = invoke(:status, '@break', 'has_output')
    assert_equal(:idle, br3ak.status_name)
    assert_equal(true, has_output)
    assert_equal(0, @backend.size)
  end

  def test_status_break
    invoke(:start)
    br3ak, has_output = invoke(:status, '@break', 'has_output')
    assert_equal(:break, br3ak.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

  def test_status_finished
    invoke(:start)
    invoke(:finish)
    br3ak, has_output = invoke(:status, '@break', 'has_output')
    assert_equal(:finished, br3ak.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

