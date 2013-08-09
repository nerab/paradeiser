require 'helper'
require 'tmpdir'

class TestPomodoroHooks < MiniTest::Test
  def setup
    @orig_pom_dir = ENV['POM_DIR']
    ENV['POM_DIR'] = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(Paradeiser.pom_dir)
    ENV['POM_DIR'] = @orig_pom_dir
  end

  def test_before_finish_success
    hook_name = 'before-finish'
    token_file = create_hook(hook_name)

    pom = Pomodoro.new
    pom.start
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")
    pom.finish
    assert_path_exists(token_file, "#{hook_name} hook should have created a token file")
    assert_equal(:finished, pom.status_name)
  end

  def test_before_finish_error
    hook_name = 'before-finish'
    token_file = create_hook(hook_name, false)

    pom = Pomodoro.new
    pom.start
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")

    assert_raises HookFailedError do
      pom.finish
    end

    refute_path_exists(token_file, "#{hook_name} hook should have created a token file")
    assert_equal(:active, pom.status_name)
  end

private

  def create_hook(name, hook_succeeds = true)
    token_file = File.join(Dir.tmpdir, SecureRandom.uuid)

    hooks_dir = Paradeiser.hooks_dir
    FileUtils.mkdir(hooks_dir)

    hook_file = File.join(hooks_dir, name)

    File.open(hook_file, 'w') do |f|
      if hook_succeeds
        f.write(hook_contents_success(token_file))
      else
        f.write(hook_contents_failure)
      end
    end

    File.chmod(0700, hook_file)

    assert(File.exist?(hook_file))
    token_file
  end

  def hook_contents_success(token_file)
    hook_contents =<<"EOF"
#!/bin/sh
touch #{token_file}
EOF
  end

  def hook_contents_failure
    hook_contents =<<"EOF"
#!/bin/sh
exit 1
EOF
  end
end
