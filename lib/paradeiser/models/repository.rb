module Paradeiser
  class Repository
    class << self
      def all
        backend.transaction(true) do
          backend.roots.map{|id| backend[id]}
        end
      end

      def all_pomodori
        all.select{|p| p.kind_of?(Pomodoro)}
      end

      def all_breaks
        all.select{|b| b.kind_of?(Break)}
      end

      def any?(&blk)
        all.any?(&blk)
      end

      def find(&blk)
        all.select(&blk)
      end

      def active
        all_active = find{|pom| pom.active?}.sort{|a,b| a.started_at <=> b.started_at}

        # Cannot recover from an internal inconsistency.
        if all_active.size > 1
          raise "The repository was corrupted. There are #{all_active.size} active objects, but only one is allowed to be active."
        end

        all_active.last
      end

      def active?
        !!active
      end

      def last_finished
        find{|p| p.finished?}.sort{|a,b| a.started_at <=> b.started_at}.last
      end

      def last_canceled
        find{|p| p.canceled?}.sort{|a,b| a.started_at <=> b.started_at}.last
      end

      def save(pom)
        raise IllegalStatusError if pom.idle?

        # Do not allow saving of a new active pomodoro while another pomodoro or break is active
        raise SingletonError.new(pom.class, self.active, :save) if self.active? && pom.new?

        pom.id = next_id if pom.new?
        backend.transaction do
          backend[pom.id] = pom
        end
      end

      def next_id
        if all.empty?
          1
        else
          all.max{|a, b| a.id <=> b.id}.id.next
        end
      end

    private

      def backend
        begin
          @backend ||= PStore.new(File.join(Paradeiser.par_dir, 'repository.pstore'), true)
        rescue PStore::Error => e
          raise NotInitializedError.new(e.message)
        end
      end
    end
  end
end
