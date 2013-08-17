require 'helper'

module Paradeiser
  #
  # We put all integration tests into separate files so we only run one at a
  # time after a change. These tests are expensive to run.
  #
  class IntegrationTest < MiniTest::Test
    PAR = 'bin/par'

    def setup
      @orig_PAR_DIR = ENV['PAR_DIR']
      ENV['PAR_DIR'] = Dir.mktmpdir
      assert_command('init')
    end

    def teardown
      FileUtils.rm_rf(Paradeiser.par_dir)
      ENV['PAR_DIR'] = @orig_PAR_DIR
    end

    def assert_command(cmd, expected_status = 0)
      out, err, status = Open3.capture3("#{PAR} #{cmd}")
      assert_equal(expected_status, status.exitstatus, "Expected exit status to be #{expected_status}, but it was #{status.exitstatus}. STDERR is: '#{err}'")
      assert_empty(err)
      out
    end

    def refute_command(cmd, expected_status = 1)
      out, err, status = Open3.capture3("#{PAR} #{cmd}")
      assert_equal(expected_status, status.exitstatus, "Expected exit status to be #{expected_status}, but it was #{status.exitstatus}.")
      [out, err]
    end
  end
end
