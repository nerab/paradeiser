module Paradeiser
  class Controller
    def initialize(method)
      @method = method
    end

    def call(args, options)
      @options = options
      @args = args
      send(@method)
      STDOUT.puts ERB.new(File.read(File.join(File.dirname(__FILE__), '..', 'views', model_name, "#{@method}.erb")), 0, "%<>").result(binding)
    end

  protected

    attr_reader :options, :args

    def model_name
      self.class.to_s.split("::").last.sub('Controller', '').downcase
    end
  end
end
