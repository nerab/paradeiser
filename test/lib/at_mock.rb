# Include this module in order to use another queue for at commands
module Executor
  def queue
    ENV['PAR_AT_QUEUE'] || 't'
  end
end
