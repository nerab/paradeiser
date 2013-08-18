module Paradeiser
  class SingletonError < StandardError
    def initialize(new_resource, existing_resource, verb)
      super("Cannot #{verb} the #{new_resource.name.split("::").last.downcase} because #{existing_resource.name} ##{existing_resource.id} is active")
    end
  end

  class NotActiveError < StandardError
    def initialize
      super('There is no active pomodoro or break')
    end
  end

  class NotInitializedError < StandardError
    def initialize(msg)
      super("Paradeiser was not properly initialized; #{msg}")
    end
  end

  class IllegalStatusError < StandardError
    def initialize
      super('Idle pomodori cannot be saved')
    end
  end

  class HookFailedError < StandardError
    def initialize(hook, out, err, status)
      super("The hook #{hook} failed with status #{status.exitstatus}. STDERR contained: #{err}")
    end
  end

  class InvalidTypeError < StandardError
    def initialize(type, choices)
      super("'#{type}' is not a valid type. Valid are only #{choices}.")
    end
  end

  class MissingAnnotationError < StandardError
    def initialize
      super('The mandatory text is missing for the annotation')
    end
  end
end
