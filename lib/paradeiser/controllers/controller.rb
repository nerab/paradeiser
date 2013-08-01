module Paradeiser
  class Controller
    attr_reader :exitstatus

    def initialize(method)
      @method = method
      @exitstatus = 0
      @print = false
    end

    def call(args, options)
      @args = args
      @options = options
      send(@method)
      options_sane?(options)
      puts(template.result(binding)) if print?(options)
    end

  protected

    attr_reader   :options, :args
    attr_accessor :print
    attr_writer   :exitstatus

    def model_name
      self.class.to_s.split("::").last.sub('Controller', '').downcase
    end

    def template
      ERB.new(File.read(template_file), 0, '%<>')
    end

    def template_file
      File.join(File.dirname(__FILE__), '..', 'views', model_name, "#{@method}.erb")
    end

  private
    def options_sane?(options)
      raise ContradictingOptionsError.new(:verbose, :quiet) if options.verbose && options.quiet
    end

    def print?(options)
      options.verbose && !options.quiet || !options.verbose && !options.quiet && print
    end
  end
end
