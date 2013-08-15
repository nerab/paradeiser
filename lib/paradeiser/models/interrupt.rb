module Paradeiser
  class Interrupt
    KNOWN_TYPES = [:internal, :external]
    attr_reader :created_at, :type

    def initialize(type = :internal)
      raise InvalidTypeError.new(type, KNOWN_TYPES) unless KNOWN_TYPES.include?(type)
      @type = type
      @created_at = Time.now
    end
  end

  class ExternalInterrupt < Interrupt
    def initialize
      super(:external)
    end
  end
end
