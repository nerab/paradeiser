require 'helper'
require 'fakefs/safe'

class TestPomodoroHooks < MiniTest::Test
  def setup
    @pom = Pomodoro.new
    FakeFS.activate!
  end

  def teardown
    FileUtils.rm_rf(Paradeiser.pom_dir)
    FakeFS.deactivate!
  end

  def test_pre_finish
    hook_name = 'pre-finish'
    token_file = create_hook(hook_name)

    @pom.start
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")
    @pom.finish
    assert_path_exists(token_file, "#{hook_name} hook should have created a token file")
  end

private

  def create_hook(name)
    token_file = File.join('/tmp', SecureRandom.uuid)
    hook_contents =<<"EOF"
#!/bin/sh
touch #{token_file}
EOF

    FileUtils.mkdir_p('/tmp')
    hooks_dir = File.join(Paradeiser.pom_dir, 'hooks')
    FileUtils.mkdir_p(hooks_dir, 0700)

    hook_file = File.join(hooks_dir, name)

    File.open(hook_file, 'w') do |f|
      f.write(hook_contents)
    end

    assert(File.exist?(hook_file))
    token_file
  end
end
