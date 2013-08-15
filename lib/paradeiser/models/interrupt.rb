module Paradeiser
  class AbstractInterrupt
    attr_reader :created_at, :type

  protected

    def initialize
      @created_at = Time.now
    end

    attr_writer :type
  end

  class Interrupt < AbstractInterrupt
    attr_reader :type

    def initialize
      super
      self.type = :internal
    end
  end

  class ExternalInterrupt < AbstractInterrupt
    attr_reader :type

    def initialize
      super
      self.type = :external
    end
  end
end
