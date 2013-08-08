module Paradeiser
  class Hook
    def initialize(phase)
      @phase = phase
    end

    def execute(transition)
      name = "#{@phase}-#{transition.event}"

      if File.exist?(hook(name))
        hook = hook(name)
        out, err, status = Open3.capture3(hook)
        raise HookFailedError.new(hook, out, err, status) if 0 != status.exitstatus
      end
    end

  private

    def hook(name)
      File.join(Paradeiser.pom_dir, 'hooks', name)
    end
  end
end
