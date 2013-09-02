require 'tmpdir'

module ParadeiserTest
  class TokenFileRegistry
    def initialize
      @token_files = []
    end

    def create
      token_file = File.join(Dir.tmpdir, SecureRandom.uuid)
      @token_files << token_file
      token_file
    end

    def cleanup
      @token_files.each{|tf| FileUtils.rm(tf) if File.exist?(tf)}
    end
  end
end
