module Executor
  def exec(cmd)
    out, err, status = Open3.capture3(cmd)
    raise err if 0 < status.exitstatus
    [out, err]
  end

  def at
    'at'
  end

  def queue
    'p'
  end
end
