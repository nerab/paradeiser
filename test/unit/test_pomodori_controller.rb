require 'helper'

class TestPomodoriController < ControllerTest
  def setup
    @backend = PStoreMock.new
  end

  def model
    'pomodoro'
  end

  def test_start
    attrs = invoke(:start, nil, nil, '@pom', 'has_output')
    assert_equal(:active, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_start_verbose
    attrs = invoke(:start, nil, OpenStruct.new(:verbose => true), '@pom', 'has_output')
    assert_equal(:active, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    refute_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_start_active
    invoke(:start)
    assert_equal(1, @backend.size)

    assert_raises SingletonError do
      invoke(:start)
    end
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:start)
    attrs = invoke(:finish, nil, nil, '@pom', 'has_output')
    assert_equal(:finished, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_finish_verbose
    invoke(:start)
    attrs = invoke(:finish, nil, OpenStruct.new(:verbose => true), '@pom', 'has_output')
    assert_equal(:finished, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    refute_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_finish_idle
    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end

  def test_finish_canceled
    invoke(:start)
    invoke(:cancel)
    assert_equal(1, @backend.size)

    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(1, @backend.size)
    assert_equal(:canceled, @backend[@backend.roots.first].status_name)
  end

  def test_interrupt_idle
    assert_raises NotActiveError do
      invoke(:interrupt)
    end
    assert_equal(0, @backend.size)
  end

  def test_interrupt_active
    invoke(:start)
    attrs = invoke(:interrupt, nil, OpenStruct.new, '@pom', 'has_output')
    assert_equal(:active, attrs[:pom].status_name)
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])

    interrupts = attrs[:pom].interrupts
    refute_nil(interrupts)
    refute_empty(interrupts)
    assert_equal(1, interrupts.size)

    interrupt = interrupts.first
    refute_nil(interrupt)
    refute_nil(interrupt.created_at)
    assert_equal(:internal, interrupt.type)
  end

  def test_interrupt_active_verbose
    invoke(:start)
    attrs = invoke(:interrupt, nil, OpenStruct.new(:verbose => true), '@pom', 'has_output')
    assert_equal(:active, attrs[:pom].status_name)
    refute_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
  end

  def test_interrupt_active_internal
    invoke(:start)
    attrs = invoke(:interrupt, nil, OpenStruct.new(:internal => true), '@pom')
    interrupt = attrs[:pom].interrupts.first
    assert_equal(:internal, interrupt.type)
  end

  def test_interrupt_active_external
    invoke(:start)
    attrs = invoke(:interrupt, nil, OpenStruct.new(:external => true), '@pom')
    interrupt = attrs[:pom].interrupts.first
    assert_equal(:external, interrupt.type)
  end

  def test_interrupt_finished
    invoke(:start)
    invoke(:finish)
    assert_equal(1, @backend.size)

    assert_raises NotActiveError do
      invoke(:interrupt)
    end

    assert_equal(1, @backend.size)
  end

  def test_cancel_idle
    assert_raises NotActiveError do
      invoke(:cancel)
    end
    assert_equal(0, @backend.size)
  end

  def test_cancel_active
    invoke(:start)
    attrs = invoke(:cancel, nil, nil, '@pom', 'has_output')
    assert_equal(:canceled, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_cancel_active_verbose
    invoke(:start)
    attrs = invoke(:cancel, nil, OpenStruct.new(:verbose => true), '@pom', 'has_output')
    assert_equal(:canceled, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    refute_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
  end

  def test_cancel_finished
    invoke(:start)
    invoke(:finish)
    assert_equal(1, @backend.size)

    assert_raises NotActiveError do
      invoke(:cancel)
    end

    assert_equal(1, @backend.size)
  end

  def test_cancel_again
    invoke(:start)
    invoke(:cancel)
    assert_equal(1, @backend.size)
    invoke(:start)
    assert_equal(2, @backend.size)
  end

  def test_annotate_active
    invoke(:start)
    annotation_args = 'foobar w00t'.split
    attrs = invoke(:annotate, annotation_args, nil, '@pom', 'has_output')
    assert_equal(:active, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
    annotations = attrs[:pom].annotations
    assert(annotations)
    assert_equal(1, annotations.size)
    assert_equal(annotation_args.join(' '), annotations.first)
  end

  def test_annotate_active_verbose
    invoke(:start)
    attrs = invoke(:annotate, ['annotation', 'args'], OpenStruct.new(:verbose => true), '@pom', 'has_output')
    refute_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
  end

  def test_annotate_second_last_successful
    invoke(:start)
    invoke(:finish)

    @backend[:foo] = SchedulableMock.new(
      :status => 'finished',
      :status_name => :finished,
      :finished => true,
      :name => 'break',
      :remaining => 0,
      :finished_at => Time.now)


    last = Repository.stub :backend, @backend do
      Repository.all.last
    end
    assert_kind_of(SchedulableMock, last)

    annotation_args = name.split('_')
    attrs = invoke(:annotate, annotation_args, nil, '@pom', 'has_output')

    pom = attrs[:pom]
    assert_kind_of(Pomodoro, pom)
    assert_equal(:finished, pom.status_name)

    annotations = pom.annotations
    assert(annotations)
    assert_equal(1, annotations.size)
    assert_equal(annotation_args.join(' '), annotations.first)
  end

  def test_annotate_last_successful
    invoke(:start)
    invoke(:finish)
    annotation_args = name.split('_')
    attrs = invoke(:annotate, annotation_args, nil, '@pom', 'has_output')
    assert_equal(:finished, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
    annotations = attrs[:pom].annotations
    assert(annotations)
    assert_equal(1, annotations.size)
    assert_equal(annotation_args.join(' '), annotations.first)
  end

  def test_annotate_last_canceled
    invoke(:start)
    invoke(:cancel)
    annotation_args = name.split('_')
    attrs = invoke(:annotate, annotation_args, nil, '@pom', 'has_output')
    assert_equal(:canceled, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
    annotations = attrs[:pom].annotations
    assert(annotations)
    assert_equal(1, annotations.size)
    assert_equal(annotation_args.join(' '), annotations.first)
  end

  def test_annotate_finish
    invoke(:start)
    annotation_args = name.split('_')
    attrs = invoke(:finish, annotation_args, nil, '@pom', 'has_output')
    assert_equal(:finished, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
    annotations = attrs[:pom].annotations
    assert(annotations)
    assert_equal(1, annotations.size)
    assert_equal(annotation_args.join(' '), annotations.first)
  end

  def test_annotate_interrupt
    invoke(:start)
    annotation_args = name.split('_')
    attrs = invoke(:interrupt, annotation_args, OpenStruct.new, '@pom', 'has_output')
    assert_equal(:active, attrs[:pom].status_name)
    assert_equal(false, attrs[:has_output])
    assert_empty(attrs[:stdout])
    assert_empty(attrs[:stderr])
    assert_equal(1, @backend.size)
    annotations = attrs[:pom].annotations
    assert(annotations)
    assert_equal(1, annotations.size)
    assert_equal(annotation_args.join(' '), annotations.first)
  end
end
