require 'helper'

class TestRepository < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_save_idle
    pom = Pomodoro.new

    assert_raises IllegalStatusError do
      invoke(:save, pom)
    end

    assert_equal(0, @backend.size)
  end

  def test_save_active
    pom = Pomodoro.new
    start!(pom)

    invoke(:save, pom)

    assert_equal(1, @backend.size)
  end

  def test_save_second_active
    pom1 = Pomodoro.new
    start!(pom1)

    pom2 = Pomodoro.new
    start!(pom2)

    invoke(:save, pom1)

    assert_raises SingletonError do
      invoke(:save, pom2)
    end

    assert_equal(1, @backend.size)
  end

  def test_save_finished
    pom = Pomodoro.new
    start!(pom)
    finish!(pom)

    invoke(:save, pom)

    assert_equal(1, @backend.size)
  end

  def test_save_active_finish_save
    pom = Pomodoro.new
    start!(pom)

    invoke(:save, pom)
    finish!(pom)
    invoke(:save, pom)

    assert_equal(1, @backend.size)
  end

  def test_all
    @backend[:foo] = 'bar'
    assert_equal(1, @backend.size)

    all = invoke(:all)

    assert_equal(1, all.size)
  end

  def test_any
  end

  def test_find
    @backend[:foo] = PomodoroMock.new(:length => 3)
    @backend[:bar] = PomodoroMock.new(:length => 3)
    @backend[:baz] = PomodoroMock.new(:length => 2)
    assert_equal(3, @backend.size)

    all = invoke(:find){|pom| pom.length == 3}

    assert_equal(2, all.size)
  end

  def test_active
    @backend[:foo] = PomodoroMock.new(:active => false)
    @backend[:bar] = PomodoroMock.new(:active => true)
    @backend[:baz] = PomodoroMock.new(:active => false)

    active = invoke(:active)
    assert_equal(@backend[:bar], active)
  end

  def test_active_true
    @backend[:foo] = PomodoroMock.new(:active => false)
    @backend[:bar] = PomodoroMock.new(:active => true)
    @backend[:baz] = PomodoroMock.new(:active => false)

    assert(invoke(:active?))
  end

  def test_active_false
    @backend[:foo] = PomodoroMock.new(:active => false)
    @backend[:bar] = PomodoroMock.new(:active => false)
    @backend[:baz] = PomodoroMock.new(:active => false)

    refute(invoke(:active?))
  end

  def test_corrupted_repo
    @backend[:foo] = PomodoroMock.new(:active => true)
    @backend[:bar] = PomodoroMock.new(:active => true)

    assert_raises RuntimeError do
      invoke(:active?)
    end
  end
private

  def invoke(method, *args, &blk)
    Repository.stub :backend, @backend do
      Repository.send(method, *args, &blk)
    end
  end
end
