require 'helper'

class TestScheduler < MiniTest::Test
  def test_add
    result = invoke(:list, ['', nil, ProcessStatusMock.new(0)])
    assert_equal(0, result.size)

    job = invoke(:add, [nil, 'job 11 at Sun Aug  4 22:08:00 2013', ProcessStatusMock.new(0)], :finish, 42)
    refute_nil(job)
    assert_equal(11, job.id.to_i)

    list = invoke(:list, ['11 Sun Aug  4 22:08:00 2013', nil, ProcessStatusMock.new(0)])
    assert_equal(1, list.size)
    assert_equal(job, list.first)
  end

  def test_clear
    specs = [
      'job 13 at Sun Aug  4 22:08:00 2013',
      'job 14 at Sun Aug  4 22:08:00 2013',
      'job 15 at Sun Aug  4 22:08:00 2013'
    ]

    specs.each do |spec|
      add(:err => spec)
    end

    result = invoke(:list, [specs.join($/), nil, ProcessStatusMock.new(0)])
    assert_equal(specs.size, result.size)

    clear

    result = invoke(:list, [specs.join($/), nil, ProcessStatusMock.new(0)])
    assert_equal(0, result.size)
  end

private

  def add(options = {})
    options.merge!({
      :status => 0,
      :method => :finish,
      :minutes => 11
    })

    invoke(:add, [options[:out], options[:err], ProcessStatusMock.new(options[:status])], options[:method], options[:minutes])
  end

  def clear
    invoke(:clear, [$/, nil, ProcessStatusMock.new(0)])
  end

  def invoke(method, result, *args)
    Open3.stub(:capture3, result) do
      Paradeiser::Scheduler.send(method, *args)
    end
  end
end
