module Paradeiser
  class Repository
    class << self
      def all
        backend.transaction(true) do
          backend.roots.map{|id| backend[id]}
        end
      end

      def any?(&blk)
        all.any?(&blk)
      end

      def find(&blk)
        all.select(&blk)
      end

      def active
        all_active = find{|pom| pom.active?}.sort{|p| p.started_at}
        raise SingletonError.new(all_active.first) if all_active.size > 1
        all_active.first
      end

      def active?
        !!active
      end

      def save(pom)
        raise IllegalStatusError if pom.idle?
        raise SingletonError.new(self.active) if self.active? && active.id != pom.id

        pom.id = next_id if pom.new?
        backend.transaction do
          backend[pom.id] = pom
        end
      end

    private

      def backend
        begin
          @backend ||= PStore.new(File.join(Paradeiser.pom_dir, 'repository.pstore'), true)
        rescue PStore::Error => e
          raise NotInitializedError.new(e.message)
        end
      end

      def next_id
        if all.empty?
          1
        else
          all.max{|a, b| a.id <=> b.id}.id + 1
        end
      end
    end
  end
end
