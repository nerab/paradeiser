module Paradeiser
  def self.pom_dir
    ENV['POM_DIR'] || File.expand_path('~/.paradeiser/')
  end

  class Repository
    class << self
      def all
        backend.transaction(true) do
          backend.roots.map{|id| backend[id]}
        end
      end

      def any?(criteria)
        find(criteria).any?
      end

      def find(criteria)
        all.select do |pom|
          # TODO Handle multiple criteria
          pom.send(criteria.keys.first) == criteria.values.first
        end
      end

      def active
        find(:status => 'active').first
      end

      def active?
        !!active
      end

      def save(pom)
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
