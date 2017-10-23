require 'helper'

module ParadeiserTest
  class TestScheduler < UnitTest
    def initialize(*args)
      super(*args)
      @do_not_clear = nil
    end

    def setup
      super
      if Scheduler.list.any?
        @do_not_clear = true
        raise "The at queue '#{queue}' is not empty. Clean it up before running this test again."
      end
    end

    def teardown
      super
      Scheduler.clear unless @do_not_clear
    end

    def test_add
      result = Scheduler.list
      assert_equal(0, result.size)

      job = Scheduler.add(:finish, 42)
      refute_nil(job)
      refute_nil(job.id)
      assert(0 < job.id.to_i)

      list = Scheduler.list
      assert_equal(1, list.size)
      assert_equal(job, list.first)
    end

    def test_clear
      n = 3

      n.times.each do |spec|
        Scheduler.add(:finish, 43)
      end

      result = Scheduler.list
      assert_equal(n, result.size)

      Scheduler.clear

      result = Scheduler.list
      assert_equal(0, result.size)
    end
  end
end
