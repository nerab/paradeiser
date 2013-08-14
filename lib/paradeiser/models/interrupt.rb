module Paradeiser
  class Interrupt
    attr_reader :created_at

    def initialize
      @created_at = Time.now
    end
  end
end
