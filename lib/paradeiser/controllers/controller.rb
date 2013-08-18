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
      render
    end

    def model
      self.class.name.split("::").last.sub('Controller', '')
    end

    def get_binding
      return binding
    end

    def render(options = {})
      return if @already_rendered # render only once
      return unless (@options && @options.verbose) || has_output

      if options.has_key?(:text)
        puts options[:text]
      else
        puts View.new(model, @method).render(binding)
      end

      @already_rendered = true
    end

  protected

    attr_writer :exitstatus, :has_output
    attr_reader :options, :args
  end
end
