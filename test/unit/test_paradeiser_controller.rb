require 'helper'
require 'fakefs/safe'

class TestParadeiserController < MiniTest::Test
  def setup
    @orig_pom_dir = ENV['POM_DIR']
    FakeFS.activate!
  end

  def teardown
    FakeFS.deactivate!
    ENV['POM_DIR'] = @orig_pom_dir
  end

  def test_init_virgin
    ENV.delete('POM_DIR')
    refute(Dir.exists?(Paradeiser.pom_dir), "Expect #{Paradeiser.pom_dir} to not exist yet")

    ParadeiserController.new(:init).call(nil, nil)

    assert(Dir.exists?(Paradeiser.pom_dir))
  end

  def test_init_existing
    ENV.delete('POM_DIR')
    FileUtils.mkdir_p(Paradeiser.pom_dir, 0700)
    assert(Dir.exists?(Paradeiser.pom_dir))

    begin
      assert_raises AlreadyInitializedError do
        ParadeiserController.new(:init).call(nil, nil)
      end
    ensure
      FileUtils.rmdir(Paradeiser.pom_dir)
    end
  end

  def test_init_virgin_with_env_override
    dir = tempdir_name
    refute_equal(dir, Paradeiser.pom_dir)
    ENV['POM_DIR'] = dir
    assert_equal(dir, Paradeiser.pom_dir)
    refute(Dir.exists?(Paradeiser.pom_dir), "POM_DIR override #{Paradeiser.pom_dir} must not exist")

    ParadeiserController.new(:init).call(nil, nil)

    assert(Dir.exists?(Paradeiser.pom_dir))
  end

  def test_init_existing_with_env_override
    ENV.delete('POM_DIR')

    Dir.mktmpdir do |dir|
      refute_equal(dir, Paradeiser.pom_dir)
      ENV['POM_DIR'] = dir
      assert_equal(dir, Paradeiser.pom_dir)
      assert(Dir.exists?(Paradeiser.pom_dir), "POM_DIR override #{Paradeiser.pom_dir} must exist")

      assert_raises AlreadyInitializedError do
        ParadeiserController.new(:init).call(nil, nil)
      end
    end
  end

private

  # Makes a temporary directory name, but does not create the directory
  def tempdir_name
    dir = File.join(Dir.tmpdir, SecureRandom.uuid)
    refute(Dir.exists?(dir))
    dir
  end
end
