require 'active_support/core_ext/enumerable'

module Paradeiser
  class Scheduled
    attr_accessor :id, :started_at, :finished_at

    def initialize
      @id = nil
    end

    def new?
      @id.nil?
    end

    # from https://github.com/travis-ci/travis/blob/master/lib/travis/client/job.rb
    def duration
      start  = started_at  || Time.now
      finish = finished_at || Time.now
      (finish - start).to_i
    end

    def remaining
      raise NotActiveError unless active?
      length - Time.now.to_i + started_at.to_i
    end

    def name
      self.class.name.split("::").last.downcase
    end

    def as_json(*options)
      {:type => name.titlecase, :length => length}.merge(super(*options))
    end
  end
end
