module Paradeiser
  class Break < Scheduled
    def initialize(length = 300)
      super()
      @length = length
    end

    def length
      raise NotActiveError unless active?
      @length
    end
  end
end
