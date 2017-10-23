require 'helper'
require 'fakefs/safe'

class TestParadeiserControllerInit < MiniTest::Test
  HOOKS = ['after-finish', 'before-finish']

  def setup
    @orig_PAR_DIR = ENV['PAR_DIR']
    FakeFS.activate!
    create_hook_templates
  end

  def teardown
    FileUtils.rm_r(Paradeiser.par_dir, :force => true) if Dir.exists?(Paradeiser.par_dir)
    FakeFS.deactivate!
    ENV['PAR_DIR'] = @orig_PAR_DIR
  end

  def test_init_virgin
    ENV.delete('PAR_DIR')
    refute(Dir.exists?(Paradeiser.par_dir), "Expect #{Paradeiser.par_dir} to not exist yet")

    invoke(:init)
    assert(Dir.exists?(Paradeiser.par_dir))
    assert_hooks_exist
  end

  def test_init_existing
    FileUtils.mkdir_p(Paradeiser.par_dir, mode: 0700)
    assert(Dir.exists?(Paradeiser.par_dir))

    invoke(:init)
    assert(Dir.exists?(Paradeiser.par_dir))
    assert_hooks_exist
  end

  def test_init_virgin_with_env_override
    dir = tempdir_name
    refute_equal(dir, Paradeiser.par_dir)
    ENV['PAR_DIR'] = dir
    assert_equal(dir, Paradeiser.par_dir)
    refute(Dir.exists?(Paradeiser.par_dir), "PAR_DIR override #{Paradeiser.par_dir} must not exist")

    invoke(:init)

    assert(Dir.exists?(Paradeiser.par_dir))
    assert_hooks_exist
  end

  def test_init_existing_with_env_override
    ENV.delete('PAR_DIR')

    Dir.mktmpdir(name) do |dir|
      refute_equal(dir, Paradeiser.par_dir)
      ENV['PAR_DIR'] = dir
      assert_equal(dir, Paradeiser.par_dir)
      assert(Dir.exists?(Paradeiser.par_dir), "PAR_DIR override #{Paradeiser.par_dir} must exist")

      invoke(:init)
      assert(Dir.exists?(Paradeiser.par_dir), "PAR_DIR override #{Paradeiser.par_dir} must exist")
      assert_hooks_exist
    end
  end

private

  def invoke(verb)
    ParadeiserController.new(verb).call(nil, nil)
  end

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
