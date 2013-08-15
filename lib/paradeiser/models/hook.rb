module Paradeiser
  class Hook
    def initialize(phase)
      @phase = phase
    end

    def execute(pom, event)
      name = "#{@phase}-#{event}-#{pom.name}"
      hook = hook(name)

      if File.exist?(hook) && File.executable?(hook)
        ENV["PAR_#{pom.name.upcase}_ID"] = pom.id ? pom.id.to_s : Repository.next_id.to_s
        ENV["PAR_#{pom.name.upcase}_STARTED_AT"] = pom.started_at.strftime('%H:%M') if pom.started_at

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
