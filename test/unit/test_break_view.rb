require 'helper'

class TestBreakView < ViewTest
  def setup
    @break = Break.new
    @break.id = 1
  end

  def test_start
    assert_match(/^Starting a new break \(5 minutes\)\.$/m, render(:start))
  end

  def test_finish
    start!
    assert_match(/^Finished break #1 after .* minutes\.$/m, render(:finish))
  end

protected

  def model
    'Break'
  end
end
