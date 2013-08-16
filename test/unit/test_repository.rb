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
    refute(invoke(:any?){|p| p.length > 2})
    @backend[:foo] = SchedulableMock.new(:length => 1)
    @backend[:bar] = SchedulableMock.new(:length => 2)
    @backend[:baz] = SchedulableMock.new(:length => 3)
    assert(invoke(:any?){|p| p.length > 2})
  end

  def test_last_finished
    @backend[:foo] = SchedulableMock.new(:finished => false)
    @backend[:bar] = SchedulableMock.new(:finished => true)
    @backend[:baz] = SchedulableMock.new(:finished => false)

    last_finished = invoke(:last_finished)
    assert(last_finished)
   end

  def test_last_canceled
    @backend[:foo] = SchedulableMock.new(:canceled => false)
    @backend[:bar] = SchedulableMock.new(:canceled => true)
    @backend[:baz] = SchedulableMock.new(:canceled => false)

    last_canceled = invoke(:last_canceled)
    assert(last_canceled)
  end

  def test_find
    @backend[:foo] = SchedulableMock.new(:length => 3)
    @backend[:bar] = SchedulableMock.new(:length => 3)
    @backend[:baz] = SchedulableMock.new(:length => 2)
    assert_equal(3, @backend.size)

    all = invoke(:find){|pom| pom.length == 3}

    assert_equal(2, all.size)
  end

  def test_active
    @backend[:foo] = SchedulableMock.new(:active => false)
    @backend[:bar] = SchedulableMock.new(:active => true)
    @backend[:baz] = SchedulableMock.new(:active => false)

    active = invoke(:active)
    assert_equal(@backend[:bar], active)
  end

  def test_active_true
    @backend[:foo] = SchedulableMock.new(:active => false)
    @backend[:bar] = SchedulableMock.new(:active => true)
    @backend[:baz] = SchedulableMock.new(:active => false)

    assert(invoke(:active?))
  end

  def test_active_false
    @backend[:foo] = SchedulableMock.new(:active => false)
    @backend[:bar] = SchedulableMock.new(:active => false)
    @backend[:baz] = SchedulableMock.new(:active => false)

    refute(invoke(:active?))
  end

  def test_corrupted_repo
    @backend[:foo] = SchedulableMock.new(:active => true)
    @backend[:bar] = SchedulableMock.new(:active => true)

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
