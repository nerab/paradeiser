module Paradeiser
  class Hook
    def initialize(phase)
      @phase = phase
    end

    def execute(pom, transition)
      name = "#{@phase}-#{transition.event}"
      hook = hook(name)

      if File.exist?(hook) && File.executable?(hook)
        ENV['POM_ID'] = pom.id.to_s
        ENV['POM_STARTED_AT'] = pom.started_at.strftime('%H:%M') if pom.started_at

        out, err, status = Open3.capture3(hook)
        raise HookFailedError.new(hook, out, err, status) if 0 != status.exitstatus
      end
    end

  private

    def hook(name)
      File.join(Paradeiser.hooks_dir, name)
    end
  end
end
