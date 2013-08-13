require 'helper'

class TestPar < MiniTest::Test
  PAR = 'bin/par'

  def test_no_args_defaults_to_help
    out, err, status = Open3.capture3(PAR)
    assert_equal(0, status.exitstatus, "Expected exit status to be 0, but it was #{status.exitstatus}. STDERR contains: #{err}")
    assert_empty(err)
  end

  def test_unknown
    out, err, status = Open3.capture3("#{PAR} unknown")
    refute_equal(0, status.exitstatus)
    refute_empty(err)
  end
end
