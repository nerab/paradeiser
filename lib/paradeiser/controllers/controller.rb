module Paradeiser
  class Controller
    attr_reader :exitstatus, :has_output

    def initialize(method)
      @method = method
      @exitstatus = 0
      @has_output = false
    end

    def call(args, options)
      @args = args
      @options = options
      send(@method)
    end

    def model
      self.class.name.split("::").last.sub('Controller', '')
    end

    def get_binding
      return binding
    end

  protected

    attr_writer   :exitstatus, :has_output
    attr_reader   :options, :args
  end
end
