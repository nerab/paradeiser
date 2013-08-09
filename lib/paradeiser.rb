require 'pstore'
require 'erb'
require 'state_machine'

require 'require_all'
require_rel "paradeiser"

module Paradeiser
  def self.pom_dir
    ENV['POM_DIR'] || File.expand_path('~/.paradeiser/')
  end

  def self.hooks_dir
    File.join(Paradeiser.pom_dir, 'hooks')
  end

  def self.templates_dir
    File.join(File.dirname(__FILE__), '..', 'templates')
  end

  def self.os
    case RUBY_PLATFORM
      when /darwin/ then :mac
      when /linux/ then :linux
      else :other
    end
  end
end
