require 'helper'

module ParadeiserTest
  class TestBreakView < ViewTest
    def setup
      super
      @break = produce(Break)
      @break.id = 1
    end

    def test_start
      assert_match(/^Started a new break \(5 minutes\)\.$/m, render(:start))
    end

    def test_finish
      assert_match(/^Finished break #1 after .* minutes\.$/m, render(:finish))
    end

  protected

    def model
      'Break'
    end
  end
end
