require 'helper'

class TestPom < MiniTest::Test
  POM_BIN = 'pom'

  def test_no_args_defaults_to_help
    out, err, status = Open3.capture3(POM_BIN)
    assert_equal(0, status.exitstatus)
    assert_empty(err)
  end

  def test_unknown
    out, err, status = Open3.capture3("#{POM_BIN} unknown")
    refute_equal(0, status.exitstatus)
    refute_empty(err)
  end
end
