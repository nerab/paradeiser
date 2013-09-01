require 'minitest/autorun'

module ParadeiserTest
  class UnitTest < MiniTest::Test
    def setup
      # Cannot use fakefs because hooks will not execute under it, but as part of
      # the real FS. Instead, we set the $PAR_DIR to point to a temp directory
      @orig_PAR_DIR = ENV['PAR_DIR']
      ENV['PAR_DIR'] = Dir.mktmpdir
    end

    def teardown
      FileUtils.rm_rf(Paradeiser.par_dir)
      ENV['PAR_DIR'] = @orig_PAR_DIR
    end

    protected

    def produce(clazz)
      @started = srand

      Time.stub :now, Time.at(@started) do
        Scheduler.stub(:add, nil) do
          clazz.new
        end
      end
    end

    def interrupt!(type = :internal, pom = @pom)
      Scheduler.stub(:clear, nil) do
        pom.interrupt!(type)
      end
    end

    def finish!(thing = @pom || @break)
      Scheduler.stub(:clear, nil) do
        thing.finish!
      end
    end

    def cancel!(pom = @pom)
      Scheduler.stub(:clear, nil) do
        pom.cancel!
      end
    end
  end
end
