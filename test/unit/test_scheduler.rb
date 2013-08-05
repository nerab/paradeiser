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

private

  def invoke(method, result, *args)
    Open3.stub(:capture3, result) do
      Paradeiser::Scheduler.send(method, *args)
    end
  end
end
