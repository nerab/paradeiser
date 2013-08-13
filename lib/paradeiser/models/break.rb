module Paradeiser
  class Break < Scheduled
    def initialize(length = 300.seconds)
      super()
      @length = length
    end

    def length
      @length
    end
  end
end
