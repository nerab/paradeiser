module Paradeiser
  class Controller
    def initialize(command)
      @name = command.name
    end

    def call(args, options)
      @options = options
      @args = args
      send(subcommand(args))
      STDOUT.puts ERB.new(File.read(File.join(File.dirname(__FILE__), '..', 'views', "#{@name}.erb")), 0, "%<>").result(binding)
    end

    protected

    attr_reader :options, :args

    private

    def subcommand(args)
      args.shift || 'index'
    end
  end
end
