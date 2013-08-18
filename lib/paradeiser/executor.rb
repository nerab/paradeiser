module Executor
  BIN_PAR = 'par'

  def exec(cmd)
    out, err, status = Open3.capture3(cmd)
    raise err if 0 < status.exitstatus
    [out, err]
  end

  def at
    'at'
  end

  def queue
    ENV['PAR_AT_QUEUE'] || 'p'
  end
end
