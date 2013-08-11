module Paradeiser
  class Break < Scheduled
    def initialize(length = 5)
      super()
      @length = length
    end

    def length
      raise NotActiveError unless break?
      @length
    end
  end
end
