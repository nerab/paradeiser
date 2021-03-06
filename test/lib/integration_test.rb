require 'helper'
require 'shellwords'

module ParadeiserTest
  #
  # We put all integration tests into separate files so we only run one at a
  # time after a change. These tests are expensive to run.
  #
  class IntegrationTest < MiniTest::Test
    PAR = 'bin/par'
    include Executor

    def initialize(*args)
      super(*args)
      @do_not_clear = nil
    end

    def setup
      if Scheduler.list.any?
        @do_not_clear = true
        raise "The at queue '#{queue}' is not empty. Clean it up before running this test again."
      end

      @orig_PAR_DIR = ENV['PAR_DIR']
      ENV['PAR_DIR'] = Dir.mktmpdir(name)
      ENV['PAR_AT_QUEUE'] = 'i'
      assert_command('init')
    end

    def teardown
      FileUtils.rm_rf(Paradeiser.par_dir)
      ENV['PAR_DIR'] = @orig_PAR_DIR
      Scheduler.clear unless @do_not_clear
      raise "The at queue #{queue} is not empty. Clean it up before running this test again." if Scheduler.list.any?
      ENV.delete('PAR_AT_QUEUE')
    end

    def assert_command(cmd, expected_status = 0, *args)
      out, err, status = Open3.capture3("#{PAR} #{cmd} #{Shellwords.join(args)}")
      assert_equal(expected_status, status.exitstatus, "Expected exit status to be #{expected_status}, but it was #{status.exitstatus}. STDERR is: '#{err}'")
      assert_empty(err)
      out
    end

    def refute_command(cmd, expected_status = 1, *args)
      out, err, status = Open3.capture3("#{PAR} #{cmd}")
      assert_equal(expected_status, status.exitstatus, "Expected exit status to be #{expected_status}, but it was #{status.exitstatus}.")
      [out, err]
    end
  end
end
