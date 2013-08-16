require 'ostruct'

class SchedulableMock < OpenStruct
  def initialize(attributes)
    super(attributes)
  end

  def active?
    !!active
  end

  def finished?
    !!finished
  end

  def canceled?
    !!canceled
  end
end
