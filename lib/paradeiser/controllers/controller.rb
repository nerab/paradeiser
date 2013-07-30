module Paradeiser
  class Controller
    attr_reader :exitstatus

    def initialize(method)
      @method = method
      @exitstatus = 0
    end

    def call(args, options)
      @args = args
      @options = options
      send(@method)
      puts(template.result(binding)) if options.verbose || verbose
    end

  protected

    attr_reader   :options, :args
    attr_accessor :verbose
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
  end
end
