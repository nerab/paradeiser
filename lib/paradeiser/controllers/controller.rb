module Paradeiser
  class Controller
    attr_reader :exitstatus

    def initialize(method)
      @method = method
      @exitstatus = 0
      @has_output = false
    end

    def call(args, options)
      @args = args
      @options = options
      send(@method)
      puts(template.result(binding)) if options.verbose || @has_output
    end

  protected

    attr_accessor :has_output
    attr_writer   :exitstatus
    attr_reader   :options, :args

    def model_name
      self.class.to_s.split("::").last.sub('Controller', '').downcase
    end

    def template
      ERB.new(File.read(template_file), 0, '%<>')
    end

    def template_file
      File.join(File.dirname(__FILE__), '..', 'views', model_name, "#{@method}.erb")
    end
  end
end
