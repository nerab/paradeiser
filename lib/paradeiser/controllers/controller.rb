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

    def render(options)
      return if @already_rendered # only render once

      if options.has_key?(:text)
        puts options[:text]
      else
        puts View.new(model, options[:verb]).render(binding) if @options.verbose || has_output
      end

      @already_rendered = true
    end

  protected

    attr_writer :exitstatus, :has_output
    attr_reader :options, :args
  end
end
