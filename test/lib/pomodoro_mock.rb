require 'ostruct'

class PomodoroMock < OpenStruct
  def initialize(attributes)
    super(attributes)
  end

  def active?
    !!active
  end
end
