require 'helper'
require 'fakefs/safe'

class TestParadeiserController < MiniTest::Test
  HOOKS = ['after-finish', 'before-finish']

  def setup
    @orig_pom_dir = ENV['POM_DIR']
    FakeFS.activate!
    create_hook_templates
  end

  def teardown
    FileUtils.rm_r(Paradeiser.pom_dir, :force => true) if Dir.exists?(Paradeiser.pom_dir)
    FakeFS.deactivate!
    ENV['POM_DIR'] = @orig_pom_dir
  end

  def test_init_virgin
    ENV.delete('POM_DIR')
    refute(Dir.exists?(Paradeiser.pom_dir), "Expect #{Paradeiser.pom_dir} to not exist yet")

    ParadeiserController.new(:init).call(nil, nil)
    assert(Dir.exists?(Paradeiser.pom_dir))
    assert_hooks_exist
  end

  def test_init_existing
    FileUtils.mkdir_p(Paradeiser.pom_dir, 0700)
    assert(Dir.exists?(Paradeiser.pom_dir))

    ParadeiserController.new(:init).call(nil, nil)
    assert(Dir.exists?(Paradeiser.pom_dir))
    assert_hooks_exist
  end

  def test_init_virgin_with_env_override
    dir = tempdir_name
    refute_equal(dir, Paradeiser.pom_dir)
    ENV['POM_DIR'] = dir
    assert_equal(dir, Paradeiser.pom_dir)
    refute(Dir.exists?(Paradeiser.pom_dir), "POM_DIR override #{Paradeiser.pom_dir} must not exist")

    ParadeiserController.new(:init).call(nil, nil)

    assert(Dir.exists?(Paradeiser.pom_dir))
    assert_hooks_exist
  end

  def test_init_existing_with_env_override
    ENV.delete('POM_DIR')

    Dir.mktmpdir do |dir|
      refute_equal(dir, Paradeiser.pom_dir)
      ENV['POM_DIR'] = dir
      assert_equal(dir, Paradeiser.pom_dir)
      assert(Dir.exists?(Paradeiser.pom_dir), "POM_DIR override #{Paradeiser.pom_dir} must exist")

      ParadeiserController.new(:init).call(nil, nil)
      assert(Dir.exists?(Paradeiser.pom_dir), "POM_DIR override #{Paradeiser.pom_dir} must exist")
      assert_hooks_exist
    end
  end

private

  # Makes a temporary directory name, but does not create the directory
  def tempdir_name
    dir = File.join(Dir.tmpdir, SecureRandom.uuid)
    refute(Dir.exists?(dir))
    dir
  end

  def create_hook_templates
    hook_templates_dir = File.join(Paradeiser.templates_dir, Paradeiser.os.to_s, 'hooks')
    FileUtils.mkdir_p(hook_templates_dir)

    HOOKS.each do |hook|
      FileUtils.touch(File.join(hook_templates_dir, hook))
    end
  end

  def assert_hooks_exist
    HOOKS.each do |hook|
      assert(File.exist?(File.join(Paradeiser.hooks_dir, hook)))
    end
  end
end
