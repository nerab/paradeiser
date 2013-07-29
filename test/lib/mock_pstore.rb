class MockPStore
  extend Forwardable
  def_delegators :@hash, :[]=, :[], :size

  def initialize
    @hash = {}
  end

  def transaction(read_only = true)
    yield if block_given?
  end

  def roots
    @hash.keys
  end
end
