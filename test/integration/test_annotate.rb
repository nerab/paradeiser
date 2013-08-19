require 'helper'

class TestAnnotateCommand < Paradeiser::IntegrationTest
  def test_annotate_no_previous
    refute_command('annotate')
  end

  def test_annotate_active
    assert_command('start')
    assert_command('annotate', 0, name.split('_'))
  end

  def test_annotate_second_last_successful
    assert_command('start')
    assert_command('finish')
    assert_command('break')
    assert_command('annotate', 0, name.split('_'))
  end
end
