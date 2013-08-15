require 'helper'
require 'tmpdir'

class TestPomodoroHooks < MiniTest::Test
  def setup
    # Cannot use fakefs because hooks will not execute under it, but as part of
    # the real FS. Instead, we set the $PAR_DIR to point to a temp directory
    @orig_PAR_DIR = ENV['PAR_DIR']
    ENV['PAR_DIR'] = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(Paradeiser.par_dir)
    ENV['PAR_DIR'] = @orig_PAR_DIR
  end

  def test_before_start_pomodoro_success
    hook_name = 'before-start-pomodoro'
    pom = Pomodoro.new
    token_file = create_hook('Pomodoro', hook_name)
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")
    pom.start
    assert_path_exists(token_file, "#{hook_name} hook should have created a token file")
    assert_equal(:active, pom.status_name)
    assert_equal("Pomodoro #{Repository.next_id} #{pom.started_at.strftime('%H:%M')}", File.read(token_file).chomp)
  end

  def test_before_finish_pomodoro_success
    hook_name = 'before-finish-pomodoro'
    pom = Pomodoro.new
    pom.id = SecureRandom.random_number(1000)
    pom.start
    token_file = create_hook('Pomodoro', hook_name)
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")
    pom.finish
    assert_path_exists(token_file, "#{hook_name} hook should have created a token file")
    assert_equal(:finished, pom.status_name)
    assert_equal("Pomodoro #{pom.id} #{pom.started_at.strftime('%H:%M')}", File.read(token_file).chomp)
  end

  def test_before_finish_pomodoro_error
    hook_name = 'before-finish-pomodoro'
    pom = Pomodoro.new
    pom.id = SecureRandom.random_number(1000)
    pom.start
    token_file = create_hook('Pomodoro', hook_name, false)
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")

    assert_raises HookFailedError do
      pom.finish
    end

    refute_path_exists(token_file, "#{hook_name} hook should have created a token file")
    assert_equal(:active, pom.status_name)
  end

  def test_before_finish_break_success
    hook_name = 'before-finish-break'
    br3ak = Break.new
    br3ak.id = SecureRandom.random_number(1000)
    br3ak.start
    token_file = create_hook('Break', hook_name)
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")
    br3ak.finish
    assert_path_exists(token_file, "#{hook_name} hook should have created a token file")
    assert_equal(:finished, br3ak.status_name)
    assert_equal("Break #{br3ak.id} #{br3ak.started_at.strftime('%H:%M')}", File.read(token_file).chomp)
  end

  def test_before_finish_break_error
    hook_name = 'before-finish-break'
    br3ak = Break.new
    br3ak.id = SecureRandom.random_number(1000)
    br3ak.start
    token_file = create_hook('Break', hook_name, false)
    refute_path_exists(token_file, "Token file must not exist before #{hook_name} hook is executed")

    assert_raises HookFailedError do
      br3ak.finish
    end

    refute_path_exists(token_file, "#{hook_name} hook should have created a token file")
    assert_equal(:active, br3ak.status_name)
  end

private

  def create_hook(thing, hook_name, hook_succeeds = true)
    token_file = File.join(Dir.tmpdir, SecureRandom.uuid)

    hooks_dir = Paradeiser.hooks_dir
    FileUtils.mkdir(hooks_dir)

    hook_file = File.join(hooks_dir, hook_name)

    File.open(hook_file, 'w') do |f|
      if hook_succeeds
        f.write(hook_contents_success(thing, token_file))
      else
        f.write(hook_contents_failure)
      end
    end

    File.chmod(0700, hook_file)

    assert(File.exist?(hook_file))
    token_file
  end

  def hook_contents_success(thing, token_file)
    hook_contents =<<"EOF"
#!/bin/sh
echo "#{thing} $PAR_#{thing.upcase}_ID $PAR_#{thing.upcase}_STARTED_AT" > #{token_file}
EOF
  end

  def hook_contents_failure
    hook_contents =<<"EOF"
#!/bin/sh
exit 1
EOF
  end
end
